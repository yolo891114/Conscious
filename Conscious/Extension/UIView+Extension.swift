//
//  UIView+Extension.swift
//  Conscious
//
//  Created by jeff on 2023/9/12.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var csBorderColor: UIColor? {
        get {
            guard let borderColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var csBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var csBornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var csShadowColor: UIColor? {
        get {
            guard let shadowColor = layer.shadowColor else {
                return nil
            }
            return UIColor(cgColor: shadowColor)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }

    @IBInspectable var csShadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable var csShadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable var csShadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
}

@IBDesignable
class GradientView: UIView {
    var gradientLayer: CAGradientLayer!

    @IBInspectable var startColor: UIColor = .red {
        didSet {
            setupGradientLayer()
        }
    }

    @IBInspectable var endColor: UIColor = .blue {
        didSet {
            setupGradientLayer()
        }
    }

    @IBInspectable var angle: CGFloat = 0 {
        didSet {
            setupGradientLayer()
        }
    }

    @IBInspectable var shouldApplyCornerRadius: Bool = true {
        didSet {
            setupGradientLayer()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
    }

    private func setupGradientLayer() {
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            layer.addSublayer(gradientLayer)
        }

        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]

        // swiftlint:disable identifier_name
        let x: CGFloat = cos(angle * .pi / 180)
        let y: CGFloat = sin(angle * .pi / 180)
        // swiftlint:enable identifier_name

        gradientLayer.startPoint = CGPoint(x: 0.5 - x * 0.5, y: 0.5 - y * 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5 + x * 0.5, y: 0.5 + y * 0.5)

        if shouldApplyCornerRadius {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: csBornerRadius).cgPath
            gradientLayer.mask = maskLayer
        } else {
            gradientLayer.mask = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        if shouldApplyCornerRadius {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: csBornerRadius).cgPath
            gradientLayer.mask = maskLayer
        }
    }
}
