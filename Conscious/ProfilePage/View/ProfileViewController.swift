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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    private var viewModel = ProfileViewModel()
    var cancellables = Set<AnyCancellable>()

    private var passwordManager = PasswordManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }

    override func viewWillAppear(_ animated: Bool) {

        viewModel.$currentUserName
            .sink { [weak self] name in
                self?.nameLabel.text = name
            }
            .store(in: &cancellables)
        //        settingButton.titleLabel?.text = passwordManager.getPassword() == nil ? "新增密碼" : "更改密碼"
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

// MARK: DataSource

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as? ProfileTableViewCell else { return UITableViewCell() }

        if indexPath.row == 0 || indexPath.row == 1 {
            let switchView = UISwitch(frame: .zero)
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else {
            let chevronImage = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevronImage.tintColor = .B1
            cell.accessoryView = chevronImage
            cell.selectionStyle = .default
            cell.isUserInteractionEnabled = true
        }

        cell.iconView.image = UIImage(systemName: viewModel.imageArray[indexPath.row])
        cell.titleLabel.text = viewModel.titleArray[indexPath.row]
        cell.descriptionLabel.text = viewModel.descriptionArray[indexPath.row]

        return cell
    }

}

// MARK: - Function

extension ProfileViewController {

    @objc func switchChanged(_ sender: UISwitch) {
        if sender.tag == 0 && sender.isOn {
            let currentMode = PasswordMode.updating
            let viewModel = SettingPasswordViewModel(mode: currentMode)

            let settingPasswordVC = SettingPasswordViewController(viewModel: viewModel)
            settingPasswordVC.modalPresentationStyle = .overFullScreen
            self.present(settingPasswordVC, animated: true, completion: nil)
        }
    }
}
