//
//  SecondInfoViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/6.
//

import Foundation
import UIKit

class SecondInfoViewController: UIViewController {

    @IBOutlet weak var upperFlowerImage: UIImageView!
    @IBOutlet weak var lowerFlowerImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.hero.id = "showSecondInfoVC"
    }

    @IBAction func closeButtontapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0)
        rotationAnimation.duration = 1.5
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude

        self.upperFlowerImage.layer.add(rotationAnimation, forKey: "rotationAnimation")
        self.lowerFlowerImage.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}

// TODO: 檢查所有super.viewDidLoad() super.viewWillAppear()
