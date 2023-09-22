//
//  ProfileViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import UIKit
import FirebaseAuth
import Combine

class ProfileViewController: UIViewController {

    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    private var viewModel = ProfileViewModel()
    var cancellables = Set<AnyCancellable>()

    private var passwordManager = PasswordManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$currentUserName
            .sink { [weak self] name in
                self?.nameLabel.text = name
            }
            .store(in: &cancellables)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        settingButton.titleLabel?.text = passwordManager.getPassword() == nil ? "新增密碼" : "更改密碼"
    }

    @IBAction func settingButtonTapped(_ sender: UIButton) {
        let currentMode = passwordManager.getPassword() == nil ? PasswordMode.setting : PasswordMode.updating
        let viewModel = SettingPasswordViewModel(mode: currentMode)

        let settingPasswordVC = SettingPasswordViewController(viewModel: viewModel)
        settingPasswordVC.modalPresentationStyle = .automatic
        self.present(settingPasswordVC, animated: true, completion: nil)
    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {

        FirebaseManager.shared.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController {
            loginVC.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(loginVC, animated: true)
            GlobalState.isUnlock = true
        }

    }

}
