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
        label.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dateLabel)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
//        NSLayoutConstraint.activate([
//            dateLabel.snp.top
//
//            }
//
//        ])
    }
}
