//
//  LogInViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/22.
//

import Foundation
import UIKit
import Combine

// TODO: MVVM Refactor

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @Published var isLogin: Bool = false
    var loginSuccess: (() -> Void)?

    @IBAction func closeButtontapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            FirebaseManager.shared.logIn(email: email, password: password) { success in
                if success {
                    self.dismiss(animated: true)
                    self.loginSuccess?()
                } else {
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = "Invalid username or password."
                }
            }
        }

    }

    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resetVC = storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController {

            resetVC.modalPresentationStyle = .overFullScreen
            self.present(resetVC, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.isHidden = true
    }

}

// TODO: deinit Combine
