//
//  ThirdInfoViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/5.
//

import Foundation
import UIKit

class ThirdInfoViewController: UIViewController {
    @IBOutlet var characterImage: UIImageView!
    @IBOutlet var upperCloudImage: UIImageView!
    @IBOutlet var lowerCloudImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.hero.id = "showThirdInfoVC"
    }

    @IBAction func closeButtontapped(_: UIButton) {
        dismiss(animated: true)
    }

    override func viewWillAppear(_: Bool) {
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.characterImage.frame.origin.y = 50
            self.upperCloudImage.frame.origin.x = 65
            self.lowerCloudImage.frame.origin.x = 220
        })
    }
}
