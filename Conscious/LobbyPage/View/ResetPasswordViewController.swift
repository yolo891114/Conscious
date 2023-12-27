//
//  ResetPasswordViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/5.
//

import Foundation
import UIKit

class ResetPasswordViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.isHidden = true
    }

    @IBAction func closeButtontapped(_: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func submitButtonTapped(_: UIButton) {
        guard let email = emailTextField.text else { return }

        FirebaseManager.shared.resetPassword(email: email) { success in
            if success {
                self.dismiss(animated: true)
                print("Success when reseting password")

            } else {
                self.errorLabel.isHidden = false
                print("Error when reseting password")
            }
        }
    }
}
