//
//  LobbyViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/3.
//

import Foundation
import UIKit

class LobbyViewController: UIViewController {

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController {

            loginVC.modalPresentationStyle = .overFullScreen
            self.present(loginVC, animated: true)

            loginVC.loginSuccess = {
                self.dismiss(animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()


    }
}
