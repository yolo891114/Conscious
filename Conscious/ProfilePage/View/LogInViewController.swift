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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @Published var isLogin: Bool = false
    var loginSuccess: (() -> Void)?

    @IBAction func closeButtontapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }

        FirebaseManager.shared.logIn(email: email, password: password)
        self.dismiss(animated: true)
        isLogin = true
        loginSuccess?()
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

// TODO: deinit Combine
