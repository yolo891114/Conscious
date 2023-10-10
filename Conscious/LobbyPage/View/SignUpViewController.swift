//
//  SignUpViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/4.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var signupSuccess: (() -> Void)?

    @IBAction func closeButtontapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else { return }

        FirebaseManager.shared.signUp(email: email, userName: name, password: password) { success in
            if success {
                self.dismiss(animated: true)
                self.signupSuccess?()
            } else {
                print("Error when signing up")
            }

        }
    }
}
