//
//  DateCell.swift
//  Conscious
//
//  Created by Wendy_Sung on 2023/12/27.
//

import Foundation
import SnapKit
import UIKit

class DateCell: UICollectionViewCell {
    let dateNumber: Int = 1

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

//    lazy var dateButton: UIButton = {
//        let button = UIButton()
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
//        button.titleLabel?.textColor = .black
//        button.titleLabel?.textAlignment = .center
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()

    var index: IndexPath = [0, 0]

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dateLabel)
        setupUI()
    }

    // indexPath要怎麼傳進來 Delegate? Closure?

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        dateLabel.snp.makeConstraints { make in
//            make.width.height.equalTo(30)
            make.center.equalTo(self)
        }
    }
}
