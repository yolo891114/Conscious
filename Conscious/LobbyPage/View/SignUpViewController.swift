//
//  SignUpViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/4.
//

import Foundation
import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    var signupSuccess: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.isHidden = true
    }

    @IBAction func closeButtontapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.errorLabel.text = "All fields are required."
            self.errorLabel.isHidden = false
            return
        }

        FirebaseManager.shared.signUp(email: email, userName: name, password: password) { error in
            if let error = error {
                self.errorLabel.text = self.errorMessage(for: error)
                self.errorLabel.isHidden = false
                print("Error when signing up")
            } else {
                self.dismiss(animated: true)
                self.signupSuccess?()
            }
        }
    }

    func errorMessage(for error: NSError) -> String {
        if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
            switch errorCode {
            case .emailAlreadyInUse:
                return "Email already in use."
            case .weakPassword:
                return "Password should be at least 6 characters."
            case .invalidEmail:
                return "Invalid email format."
            default:
                return "An unknown error occurred."
            }
        }
        return "An unknown error occurred."
    }
}
