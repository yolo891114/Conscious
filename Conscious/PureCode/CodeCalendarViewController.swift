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

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
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

//    private let weekdayLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
//        label.textColor = .black
//        return label
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setUI()
    }

    func setUI() {
        view.backgroundColor = .systemBackground

        let weekdayString = ["日", "一", "二", "三", "四", "五", "六"]

        for index in 0 ..< weekdayString.count {
            let weekdayLabel = UILabel()
            weekdayLabel.text = weekdayString[index]
            weekdayLabel.textColor = .black
            stackView.addSubview(weekdayLabel)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        
        self.view.addSubview(collectionView)
    }
}

extension CodeCalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else { return UICollectionViewCell() }

        return cell
    }
}
