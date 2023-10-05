//
//  ResetPasswordViewController.swift
//  Conscious
//
//  Created by jeff on 2023/10/5.
//

import Foundation
import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.isHidden = true
    }

    @IBAction func closeButtontapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
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
