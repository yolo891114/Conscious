//
//  LogInViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/22.
//

import Combine
import Foundation
import UIKit

// TODO: MVVM Refactor

class LogInViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @Published var isLogin: Bool = false
    var loginSuccess: (() -> Void)?

    @IBAction func closeButtontapped(_: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func loginButtonTapped(_: UIButton) {
        if let email = emailTextField.text,
           let password = passwordTextField.text
        {
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

    @IBAction func forgotPasswordButtonTapped(_: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resetVC = storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController {
            resetVC.modalPresentationStyle = .overFullScreen
            present(resetVC, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.isHidden = true
    }
}

// TODO: deinit Combine
