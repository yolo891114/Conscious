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

class EmotionResultViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var segmentControll: UISegmentedControl!

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 205, height: 216)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    var emotionData: [EmotionRecord] = []

    private var canAddNewRecord: Bool?

    lazy var viewModel = EmotionDataViewModel()

    private var cancellables = Set<AnyCancellable>()

    @IBAction func createButtonTapped(_ sender: UIButton) {
        if let canAddNewRecord = canAddNewRecord, canAddNewRecord == false {
            showOverrideAlert()
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        viewModel.currentDataScope = sender.selectedSegmentIndex == 0 ? .month : .year
        dateLabel.text = viewModel.currentViewingDateText
        print("Current viewing date text: \(viewModel.currentViewingDateText)")
    }

    override func viewWillAppear(_ animated: Bool) {

        viewModel.canAddNewEmotionRecord()

        viewModel.fetchEmotionRecords()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                }, receiveValue: { data in
                    self.emotionData = data
                    print(data)
                }
            ).store(in: &cancellables)

        viewModel.$canAddNewRecord
            .sink { canAddNewRecord in
                self.canAddNewRecord = canAddNewRecord
            }
            .store(in: &cancellables)

        viewModel.$currentDataScope
            .sink { [weak self] _ in
                self?.dateLabel.text = self?.viewModel.currentViewingDateText
            }
            .store(in: &cancellables)

        viewModel.$dateChanged
            .sink { [weak self] _ in
                self?.dateLabel.text = self?.viewModel.currentViewingDateText
            }
            .store(in: &cancellables)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(EmotionResultCollectionViewCell.self, forCellWithReuseIdentifier: "EmotionResultCollectionViewCell")

        segmentControll.selectedSegmentIndex = viewModel.currentDataScope == .month ? 0 : 1

        let lineChartView = EmotionLineChartView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: lineChartView)

        self.addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(hostingController.view)
        self.view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),

            collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: 300),
            collectionView.heightAnchor.constraint(equalToConstant: 100)

        ])

        hostingController.didMove(toParent: self)

        self.view.bringSubviewToFront(createButton)
        self.view.bringSubviewToFront(dateLabel)
        self.view.bringSubviewToFront(segmentControll)
        self.view.bringSubviewToFront(collectionView)
    }

    func showOverrideAlert() {
        let alert = UIAlertController(title: "本週已有資料存在", message: "確定要覆蓋本週資料嗎？", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            self.viewModel.deleteCurrentWeekEmotionRecord()
            self.performSegue(withIdentifier: "showSurveySegue", sender: self)
        }))

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

}

extension EmotionResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EmotionResultCollectionViewCell",
            for: indexPath) as? EmotionResultCollectionViewCell
        else { return UICollectionViewCell() }

        cell.backgroungImage.startColor = .B6!
        cell.backgroungImage.endColor = .B3!

        return cell
    }

}

struct EmotionLineChartView: View {

    @ObservedObject var viewModel: EmotionDataViewModel

    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.filteredRecords) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Score", item.emotionScore))
                }
            }
            .frame(height: 200)
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
