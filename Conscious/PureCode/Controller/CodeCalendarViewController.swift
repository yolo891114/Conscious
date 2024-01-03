//
//  CodeCalendarViewController.swift
//  Conscious
//
//  Created by cm0679 on 2023/12/27.
//

import Foundation
import SnapKit
import UIKit

/// Wendy 可以直接使用這一頁做日曆
class CodeCalendarViewController: UIViewController {
    lazy var isoCalendar = Calendar(identifier: .iso8601) // 西曆
    lazy var lunarCalendar = Calendar(identifier: .chinese) // 農曆

    lazy var selectedYear = isoCalendar.component(.year, from: Date())
    lazy var selectedMonth = isoCalendar.component(.month, from: Date())

    lazy var dateManager = DateManager.shared

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24.0, weight: .bold)
        label.textColor = .black
        return label
    }()

    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(showPreviousMonth), for: .touchUpInside)
        return button
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(showNextMonth), for: .touchUpInside)
        return button
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        return view
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        collectionView.delegate = self
        collectionView.dataSource = self

        setupUI()
        setSelectedTimeLabel()
    }

    // MARK: - Functions

    @objc func showPreviousMonth() {
        // please optimizing this logic
        selectedMonth -= 1
        if selectedMonth < 1 {
            selectedMonth = 12
            selectedYear -= 1
        }
        setSelectedTimeLabel()
        collectionView.reloadData()
    }

    @objc func showNextMonth() {
        // please optimizing this logic
        selectedMonth += 1
        if selectedMonth > 12 {
            selectedMonth = 1
            selectedYear += 1
        }
        setSelectedTimeLabel()
        collectionView.reloadData()
    }

    func setSelectedTimeLabel() {
        monthLabel.text = "\(selectedYear) 年 \(selectedMonth) 月"
    }

    fileprivate func dehighlightCellLabel(_ cell: DateCell) {
        cell.lunarLabel.textColor = .black
        cell.lunarLabel.font = UIFont.systemFont(ofSize: 11.0, weight: .regular)
        cell.dateLabel.textColor = .black
        cell.dateLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
    }

    fileprivate func highlightCellLabel(_ cell: DateCell) {
        cell.dateLabel.textColor = .red
        cell.dateLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        cell.lunarLabel.textColor = .red
        cell.lunarLabel.font = UIFont.systemFont(ofSize: 11.0, weight: .semibold)
    }
}

// MARK: - DataSource

extension CodeCalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        let daysInMonth = dateManager.getDaysInMonth(year: selectedYear, month: selectedMonth)
        let spacing = dateManager.getSpacingDay(year: selectedYear, month: selectedMonth)
        return daysInMonth + spacing
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else { return UICollectionViewCell() }

        let spacing = dateManager.getSpacingDay(year: selectedYear, month: selectedMonth)

        if indexPath.row < spacing {
            cell.dateLabel.text = ""
            cell.lunarLabel.text = ""
        } else {
            guard let date = dateManager.getDateFrom(year: selectedYear, month: selectedMonth, day: indexPath.row + 1 - spacing) else { return cell }

            cell.lunarLabel.text = dateManager.getLunarDayString(year: selectedYear, month: selectedMonth, day: indexPath.row + 1 - spacing)
            cell.dateLabel.text = String(indexPath.row + 1 - spacing)

            dehighlightCellLabel(cell)

            if dateManager.compareTwoDateIsSame(date1: date, date2: Date()) {
                highlightCellLabel(cell)
            }
        }

        return cell
    }
}

// MARK: - SetupUI

extension CodeCalendarViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        let weekdayString = ["日", "一", "二", "三", "四", "五", "六"]

        for index in 0 ..< weekdayString.count {
            let weekdayLabel = UILabel()
            weekdayLabel.text = weekdayString[index]
            weekdayLabel.textColor = .black
            weekdayLabel.textAlignment = .center
            weekdayLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
            stackView.addArrangedSubview(weekdayLabel)
        }

        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")

        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(monthLabel)
        view.addSubview(stackView)
        view.addSubview(collectionView)

        monthLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
        }

        previousButton.snp.makeConstraints { make in
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(32)
            make.centerY.equalTo(monthLabel.snp.centerY)
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-32)
            make.centerY.equalTo(monthLabel.snp.centerY)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(450)
            make.width.equalTo(300)
        }
    }
}