//
//  UIColor+Extension.swift
//  Conscious
//
//  Created by jeff on 2023/9/22.
//

import Foundation
import UIKit

private enum CSColor: String {
    // swiftlint:disable identifier_name
    case B1
    case B2
    case B3
    case B4
    case B5
    case B6
    case G1
    // swiftlint:enable identifier_name
}

extension UIColor {

    // swiftlint:disable identifier_name
    static let B1 = CSColor(.B1)
    static let B2 = CSColor(.B2)
    static let B4 = CSColor(.B4)
    static let B5 = CSColor(.B6)
    static let G1 = CSColor(.G1)
    // swiftlint:enable identifier_name

    private static func CSColor(_ color: CSColor) -> UIColor? {
        return UIColor(named: color.rawValue)
    }

    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return .gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
