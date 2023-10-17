//
//  EmotionResultCollectionViewCell.swift
//  Conscious
//
//  Created by jeff on 2023/9/27.
//

import Foundation
import UIKit

class EmotionResultCollectionViewCell: UICollectionViewCell {

    lazy var gradientBackground: GradientView = {
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
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        label.textColor = .B3
        label.numberOfLines = 0
        label.text = "Sub Title"
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    lazy var ornamentalImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(gradientBackground)
        addSubview(ornamentalImage)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        titleLabel.lineBreakMode = .byWordWrapping

        NSLayoutConstraint.activate([
            gradientBackground.topAnchor.constraint(equalTo: topAnchor),
            gradientBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            gradientBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            gradientBackground.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: gradientBackground.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: gradientBackground.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 140),
//            titleLabel.trailingAnchor.constraint(equalTo: gradientBackground.trailingAnchor, constant: -32),

            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            subTitleLabel.leadingAnchor.constraint(equalTo: gradientBackground.leadingAnchor, constant: 16),
            subTitleLabel.trailingAnchor.constraint(equalTo: ornamentalImage.leadingAnchor, constant: -1),
            subTitleLabel.widthAnchor.constraint(equalToConstant: 90),

            ornamentalImage.trailingAnchor.constraint(equalTo: gradientBackground.trailingAnchor, constant: 16),
            ornamentalImage.bottomAnchor.constraint(equalTo: gradientBackground.bottomAnchor, constant: 16),
            ornamentalImage.widthAnchor.constraint(equalToConstant: 150),
            ornamentalImage.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
}
