//
//  ProfileViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var settingButton: UIButton!
    private var passwordManager = PasswordManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        settingButton.titleLabel?.text = passwordManager.getPassword() == nil ? "新增密碼" : "更改密碼"
    }

    @IBAction func settingButtonTapped(_ sender: UIButton) {
        let currentMode = passwordManager.getPassword() == nil ? PasswordMode.setting : PasswordMode.updating
        let viewModel = SettingPasswordViewModel(mode: currentMode)

        let settingPasswordVC = SettingPasswordViewController(viewModel: viewModel)
        settingPasswordVC.modalPresentationStyle = .automatic
        self.present(settingPasswordVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(settingPasswordVC, animated: true)
    }
}
