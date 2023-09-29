//
//  EmotionResultCollectionViewCell.swift
//  Conscious
//
//  Created by jeff on 2023/9/27.
//

import Foundation
import UIKit

class EmotionResultCollectionViewCell: UICollectionViewCell {

    lazy var backgroundImage: GradientView = {
        let image = GradientView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.shouldApplyCornerRadius = true
        return image
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        label.textColor = .B2
        label.numberOfLines = 0
        label.text = "Title"
        return label
    }()

    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        label.textColor = .B3
        label.numberOfLines = 0
        label.text = "Sub Title"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundImage)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            backgroundImage.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: backgroundImage.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: 16),

            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            subTitleLabel.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: 16),
        ])
    }
}
