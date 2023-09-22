//
//  LogInViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/22.
//

import Foundation
import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func loginButtonTapped(_ sender: UIButton) {

    }

    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else { return }

        FirebaseManager.shared.signUp(email: email, userName: name, password: password)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
