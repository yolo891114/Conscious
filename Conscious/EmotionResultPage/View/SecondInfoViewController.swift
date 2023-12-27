//
//  SecondInfoViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/6.
//

import Foundation
import UIKit

class SecondInfoViewController: UIViewController {
    @IBOutlet var upperFlowerImage: UIImageView!
    @IBOutlet var lowerFlowerImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.hero.id = "showSecondInfoVC"
    }

    @IBAction func closeButtontapped(_: UIButton) {
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0)
        rotationAnimation.duration = 1.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude

        upperFlowerImage.layer.add(rotationAnimation, forKey: "rotationAnimation")
        lowerFlowerImage.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}

// TODO: 檢查所有super.viewDidLoad() super.viewWillAppear()
