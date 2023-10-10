//
//  InfoViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/5.
//

import Foundation
import UIKit

class ThirdInfoViewController: UIViewController {

    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var upperCloudImage: UIImageView!
    @IBOutlet weak var lowerCloudImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.hero.id = "showThirdInfoVC"
    }

    @IBAction func closeButtontapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 3.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.characterImage.frame.origin.y = 50
            self.upperCloudImage.frame.origin.x = 65
            self.lowerCloudImage.frame.origin.x = 220
        })
    }
}
