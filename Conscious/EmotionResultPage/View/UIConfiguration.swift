//
//  UIConfiguration.swift
//  Conscious
//
//  Created by jeff on 2023/10/19.
//

import Foundation
import UIKit

struct UIConfiguration {
    let topColor: [UIColor] = [
        UIColor.hexStringToUIColor(hex: "CBF7E0"),
        UIColor.hexStringToUIColor(hex: "CBF4F7"),
        UIColor.hexStringToUIColor(hex: "E9F7CB"),
    ]

    let bottomColor: [UIColor] = [
        UIColor.hexStringToUIColor(hex: "BBFDFF"),
        UIColor.hexStringToUIColor(hex: "BBCAFF"),
        UIColor.hexStringToUIColor(hex: "FFCFBB"),
    ]

    let imageName: [String] = ["Excersicing",
                               "notebook",
                               "hoding_heart"]

    let titleArray: [String] = ["Emotional Health",
                                "Benefits of Journaling",
                                "Alleviate Anxiety"]

    let subtitleArray: [String] = ["To Ease Your Worries",
                                   "To Explore Your Creativity",
                                   "To Elevate Your Spirits"]

    let heroIDArray: [String] = ["showFirstInfoVC",
                                 "showSecondInfoVC",
                                 "showThirdInfoVC"]

    let directedViewControllerArray = [FirstInfoViewController.self,
                                       SecondInfoViewController.self,
                                       ThirdInfoViewController.self]
}
