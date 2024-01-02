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
    let calendar = Calendar.current
    let dates: [Date] = []

    var currentYear = Calendar.current.component(.year, from: Date())
    var currentMonth = Calendar.current.component(.month, from: Date())

    // MARK: - UI

    private let monthLabel: UILabel = {
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
        setCurrentMonthAndYear()
    }

    // MARK: - Functions

    @objc func showPreviousMonth() {
        currentMonth -= 1
        if currentMonth == 0 {
            currentMonth = 12
            currentYear -= 1
        }
        setCurrentMonthAndYear()
        collectionView.reloadData()
    }

    @objc func showNextMonth() {
        currentMonth += 1
        if currentMonth == 13 {
            currentMonth = 1
            currentYear += 1
        }
        setCurrentMonthAndYear()
        collectionView.reloadData()
    }

    func setCurrentMonthAndYear() {
        monthLabel.text = "\(currentYear) 年 \(currentMonth) 月"
    }

    func getDaysInMonth(_ currentYear: Int, _ currentMonth: Int) -> Int {
        let dateComponent = DateComponents(year: currentYear, month: currentMonth)
        guard let date = Calendar.current.date(from: dateComponent) else { return 0 }
        guard let range = Calendar.current.range(of: .day, in: .month, for: date) else { return 0 }
        return range.count
    }

    // 計算需要多少空白
    func getSpacing(_ currentYear: Int, _ currentMonth: Int) -> Int {
        let dateComponent = DateComponents(year: currentYear, month: currentMonth)
        guard let date = Calendar.current.date(from: dateComponent) else { return 0 }
        let weekday = Calendar.current.component(.weekday, from: date)

        // 假設第一天是禮拜五 則 weekday == 6 需要額外空出五格
        let spacing = weekday - 1

        return spacing
    }

    func getCurrentMonthAndDay() -> [Int] {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())
        return [currentMonth, currentDay]
    }
}

// MARK: - DataSource

extension CodeCalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        let daysInMonth = getDaysInMonth(currentYear, currentMonth)
        let spacing = getSpacing(currentYear, currentMonth)
        return daysInMonth + spacing
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else { return UICollectionViewCell() }

        let spacing = getSpacing(currentYear, currentMonth)
        let thisMonth = getCurrentMonthAndDay()[0]
        let today = getCurrentMonthAndDay()[1]

        if indexPath.row < spacing {
            cell.dateLabel.text = ""
        } else {
            cell.dateLabel.text = String(indexPath.row + 1 - spacing)
            cell.dateLabel.textColor = .black
            cell.dateLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
            if currentMonth == thisMonth && indexPath.row + 1 - spacing == today {
                cell.dateLabel.textColor = .red
                cell.dateLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
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
            make.height.equalTo(350)
            make.width.equalTo(300)
        }
    }
}
