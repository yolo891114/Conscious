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

    // 轉農曆之 Formatter
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.calendar = lunarCalendar
        formatter.dateFormat = "dd"
        return formatter
    }()

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

    private let previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(showPreviousMonth), for: .touchUpInside)
        return button
    }()

    private let nextButton: UIButton = {
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
        selectedMonth -= 1
        if selectedMonth == 0 {
            selectedMonth = 12
            selectedYear -= 1
        }
        setSelectedTimeLabel()
        collectionView.reloadData()
    }

    @objc func showNextMonth() {
        selectedMonth += 1
        if selectedMonth == 13 {
            selectedMonth = 1
            selectedYear += 1
        }
        setSelectedTimeLabel()
        collectionView.reloadData()
    }

    func setSelectedTimeLabel() {
        monthLabel.text = "\(selectedYear) 年 \(selectedMonth) 月"
    }

    func getDaysInMonth(_ currentYear: Int, _ currentMonth: Int) -> Int {
        let dateComponent = DateComponents(year: currentYear, month: currentMonth)
        guard let date = isoCalendar.date(from: dateComponent) else { return 0 }
        guard let range = isoCalendar.range(of: .day, in: .month, for: date) else { return 0 }
        return range.count
    }

    // 計算需要多少空白
    func getSpacing(_ currentYear: Int, _ currentMonth: Int) -> Int {
        let dateComponent = DateComponents(year: currentYear, month: currentMonth)
        guard let date = isoCalendar.date(from: dateComponent) else { return 0 }
        let weekday = isoCalendar.component(.weekday, from: date)

        // 假設第一天是禮拜五 則 weekday == 6 需要額外空出五格
        let spacing = weekday - 1

        return spacing
    }

    func getCurrentMonthAndDay() -> [Int] {
        let currentMonth = isoCalendar.component(.month, from: Date())
        let currentDay = isoCalendar.component(.day, from: Date())
        return [currentMonth, currentDay]
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
        let daysInMonth = getDaysInMonth(selectedYear, selectedMonth)
        let spacing = getSpacing(selectedYear, selectedMonth)
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

        let spacing = getSpacing(selectedYear, selectedMonth)
        let currentMonth = getCurrentMonthAndDay()[0]
        let today = getCurrentMonthAndDay()[1]

        if indexPath.row < spacing {
            cell.dateLabel.text = ""
            cell.lunarLabel.text = ""
        } else {
            let dateComponent = DateComponents(year: selectedYear, month: selectedMonth, day: indexPath.row + 1 - spacing)
            let date = isoCalendar.date(from: dateComponent)

            cell.lunarLabel.text = formatter.string(from: date ?? Date())
            cell.dateLabel.text = String(indexPath.row + 1 - spacing)

            dehighlightCellLabel(cell)

            if selectedMonth == currentMonth && indexPath.row + 1 - spacing == today {
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
