//
//  EmotionResultCollectionViewCell.swift
//  Conscious
//
//  Created by jeff on 2023/9/27.
//

import Foundation
import UIKit

class EmotionResultCollectionViewCell: UICollectionViewCell {

    lazy var backgroungImage = GradientView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroungImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroungImage)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        NSLayoutConstraint.activate([
            backgroungImage.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            backgroungImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backgroungImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            backgroungImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
