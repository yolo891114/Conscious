//
//  EmotionResultViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import UIKit
import SwiftUI
import Charts
import Combine
import Hero

// TODO: 檢查驚嘆號

class EmotionResultViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var lineChartBackgroundView: UIView!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    var selectedCell: UICollectionViewCell?

    var uiConfig = UIConfiguration()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 205, height: 245)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .B5
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    var emotionData: [EmotionRecord] = []

    private var canAddNewRecord: Bool?

    lazy var viewModel = EmotionResultViewModel()

    private var cancellables = Set<AnyCancellable>()

    @IBAction func createButtonTapped(_ sender: UIButton) {
        if let canAddNewRecord = canAddNewRecord, canAddNewRecord == false {
            showOverrideAlert()
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        viewModel.dataScope = sender.selectedSegmentIndex == 0 ? .month : .year
        dateLabel.text = viewModel.dateString
        print("Current viewing date text: \(viewModel.dateString)")
    }

    override func viewWillAppear(_ animated: Bool) {

        viewModel.$emotionRecords
            .sink { [weak self] records in
                self?.emotionData = records
            }
            .store(in: &cancellables)

        viewModel.$canAddNewRecord
            .sink { canAddNewRecord in
                self.canAddNewRecord = canAddNewRecord
            }
            .store(in: &cancellables)

        viewModel.$dataScope
            .sink { [weak self] _ in
                self?.dateLabel.text = self?.viewModel.dateString
            }
            .store(in: &cancellables)

        viewModel.$dateChanged
            .sink { [weak self] _ in
                self?.dateLabel.text = self?.viewModel.dateString
            }
            .store(in: &cancellables)

        viewModel.fetchEmotionRecords()
        viewModel.checkIfCanAddNewRecord()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false

        collectionView.delegate = self
        collectionView.dataSource = self
        self.hero.isEnabled = true

        collectionView.register(EmotionResultCollectionViewCell.self, forCellWithReuseIdentifier: "EmotionResultCollectionViewCell")

        segmentControll.selectedSegmentIndex = viewModel.dataScope == .month ? 0 : 1

        setupUI()
    }

}

extension EmotionResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
                        -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EmotionResultCollectionViewCell",
            for: indexPath) as? EmotionResultCollectionViewCell
        else { return UICollectionViewCell() }

        cell.gradientBackground.startColor = uiConfig.topColor[indexPath.row]
        cell.gradientBackground.endColor = uiConfig.bottomColor[indexPath.row]
        cell.gradientBackground.csBornerRadius = 15
        cell.gradientBackground.angle = 45
        cell.ornamentalImage.image = UIImage(named: uiConfig.imageName[indexPath.row])
        cell.titleLabel.text = uiConfig.titleArray[indexPath.row]
        cell.subTitleLabel.text = uiConfig.subtitleArray[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmotionResultCollectionViewCell else { return }

        cell.gradientBackground.hero.id = uiConfig.heroIDArray[indexPath.row]
        cell.hero.modifiers = [.fade, .scale(0.5)]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = "\(uiConfig.directedViewControllerArray[indexPath.row])"
        let infoVC = storyboard.instantiateViewController(withIdentifier: identifier)

        infoVC.modalPresentationStyle = .fullScreen
        infoVC.hero.isEnabled = true

        if let firstVC = infoVC as? FirstInfoViewController {
            // TODO: Enum
            present(firstVC, animated: true, completion: nil)
        } else if let secondVC = infoVC as? SecondInfoViewController {
            present(secondVC, animated: true, completion: nil)
        } else if let thirdVC = infoVC as? ThirdInfoViewController {
            present(thirdVC, animated: true, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmotionResultCollectionViewCell else { return }

        // 移除選中 cell 的 Hero ID
        cell.gradientBackground.hero.id = nil
    }
}

extension EmotionResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 計算動態大小
        let width = CGFloat(220)
        let height = collectionView.frame.height - 32
        return CGSize(width: width, height: height)
    }
}

struct EmotionLineChartView: View {

    @ObservedObject var viewModel: EmotionResultViewModel

    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.filteredRecords) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Score", item.emotionScore)
                    )
                }
                .symbol(.circle)
                .foregroundStyle(Gradient(colors: [.blue, .mint, .yellow]))
            }
            .frame(height: 180)
        }
        .gesture(
            DragGesture()
                .onEnded { value in // 判斷位移量
                    let horizontalValue = value.translation.width
                    let verticalValue = value.translation.height

                    if abs(horizontalValue) > abs(verticalValue) {
                        if horizontalValue > 0 {
                            viewModel.switchToPreviousPeriod()
                        } else {
                            viewModel.switchToNextPeriod()
                        }
                    }
                }
        )
    }
}

// MARK: - Function

// TODO: 拆分成小 function
extension EmotionResultViewController {

    func setupUI() {

        let lineChartView = EmotionLineChartView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: lineChartView)

        self.addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        lineChartBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        segmentControll.translatesAutoresizingMaskIntoConstraints = false
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(hostingController.view)
        self.view.addSubview(collectionView)

        NSLayoutConstraint.activate([

            emotionLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            emotionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),

            segmentControll.topAnchor.constraint(equalTo: emotionLabel.bottomAnchor, constant: 16),
            segmentControll.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            segmentControll.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            segmentControll.heightAnchor.constraint(equalToConstant: 25),

            lineChartBackgroundView.topAnchor.constraint(equalTo: segmentControll.bottomAnchor, constant: 16),
            lineChartBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            lineChartBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            lineChartBackgroundView.heightAnchor.constraint(equalToConstant: 300),

            dateLabel.topAnchor.constraint(equalTo: lineChartBackgroundView.topAnchor, constant: 24),
            dateLabel.leadingAnchor.constraint(equalTo: lineChartBackgroundView.leadingAnchor, constant: 24),

            hostingController.view.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: lineChartBackgroundView.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: lineChartBackgroundView.trailingAnchor, constant: -16),
            hostingController.view.bottomAnchor.constraint(equalTo: lineChartBackgroundView.bottomAnchor, constant: -16),

            infoLabel.topAnchor.constraint(equalTo: lineChartBackgroundView.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),

            collectionView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16)

        ])

        hostingController.didMove(toParent: self)

        self.view.bringSubviewToFront(createButton)
        self.view.bringSubviewToFront(dateLabel)
        self.view.bringSubviewToFront(segmentControll)
        self.view.bringSubviewToFront(collectionView)
        self.view.bringSubviewToFront(emotionLabel)
        self.view.bringSubviewToFront(infoLabel)
    }

    // TODO: Alert 拉成 Manager
    func showOverrideAlert() {
        let alert = UIAlertController(title: "本週已有資料存在", message: "確定要覆蓋本週資料嗎？", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            self.viewModel.deleteCurrentWeekRecord()
            self.performSegue(withIdentifier: "showSurveySegue", sender: self)
        }))

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}
