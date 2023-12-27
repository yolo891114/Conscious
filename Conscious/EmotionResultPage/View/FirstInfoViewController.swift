//
//  FirstInfoViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/6.
//

import Foundation
import UIKit

class FirstInfoViewController: UIViewController {
    @IBOutlet var characterImage: UIImageView!
    @IBOutlet var upperCloudImage: UIImageView!
    @IBOutlet var lowerCloudImage: UIImageView!
    @IBOutlet var upperStarImage: UIImageView!
    @IBOutlet var lowerStarImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.hero.id = "showFirstInfoVC"

        upperCloudImage.frame.origin.y = 290
        lowerCloudImage.frame.origin.y = 460
        upperStarImage.frame.origin.y = 320
        lowerStarImage.frame.origin.y = 450

        upperStarImage.transform = CGAffineTransform(rotationAngle: -(.pi / 30))
    }

    @IBAction func closeButtontapped(_: UIButton) {
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.characterImage.transform = CGAffineTransform(rotationAngle: -(.pi / 15))
        })

        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.repeat, .curveLinear], animations: {
            self.upperCloudImage.frame.origin.y = -320
        })

        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.repeat, .curveLinear], animations: {
            self.lowerCloudImage.frame.origin.y = -150
        })

        UIView.animate(withDuration: 3.0, delay: 1.0, options: [.repeat, .curveLinear], animations: {
            self.upperStarImage.frame.origin.y = -160
            self.lowerStarImage.frame.origin.y = -50
        })
    }
}
