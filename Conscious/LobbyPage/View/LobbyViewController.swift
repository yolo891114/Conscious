//
//  LobbyViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/3.
//

import Foundation
import UIKit

class LobbyViewController: UIViewController {
    @IBOutlet var cloudImage: UIImageView!
    @IBOutlet var sunImage: UIImageView!

    @IBAction func loginButtonTapped(_: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController {
            loginVC.modalPresentationStyle = .overFullScreen
            present(loginVC, animated: true)

            loginVC.loginSuccess = {
                self.dismiss(animated: true)
            }
        }
    }

    @IBAction func signupButtonTapped(_: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signupVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            signupVC.modalPresentationStyle = .overFullScreen
            present(signupVC, animated: true)

            signupVC.signupSuccess = {
                self.dismiss(animated: true)
            }
        }
    }

    override func viewWillAppear(_: Bool) {
        cloudImage.frame.origin.x = -215

        UIView.animate(withDuration: 2.5, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.cloudImage.frame.origin.x = -185
            self.sunImage.transform = CGAffineTransform(rotationAngle: -(.pi / 12))
        })
    }
}
