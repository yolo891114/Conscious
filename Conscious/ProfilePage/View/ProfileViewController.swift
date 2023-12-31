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
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!

    private var viewModel = ProfileViewModel()

    private var profileConfig = ProfileConfiguration()

    var cancellables = Set<AnyCancellable>()

    private var passwordManager = PasswordManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        nameTextField.isEnabled = false
        
    }

    override func viewWillAppear(_ animated: Bool) {

        viewModel.$currentUserName
            .sink { [weak self] name in
                self?.nameTextField.text = name
            }
            .store(in: &cancellables)

    }

    @IBAction func logoutButtonTapped(_ sender: UIButton) {

        FirebaseManager.shared.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let lobbyVC = storyboard.instantiateViewController(withIdentifier: "LobbyViewController") as? LobbyViewController {
            lobbyVC.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(lobbyVC, animated: true)
            GlobalState.isLock = false
        }
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        if nameTextField.isEditing {
            nameTextField.isEnabled = false
            editButton.setImage(UIImage(systemName: "pencil"), for: .normal)

            if let user = Auth.auth().currentUser,
               let name = nameTextField.text {
                FirebaseManager.shared.authUpdate(user: user, name: name)
            }
        } else {
            nameTextField.isEnabled = true
            nameTextField.becomeFirstResponder()
            editButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
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

        if indexPath.row == 2 {
            let chevronImage = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevronImage.tintColor = .B1
            cell.accessoryView = chevronImage
            cell.selectionStyle = .default
            cell.isUserInteractionEnabled = true
        } else {
            if indexPath.row == 1 {
                let textField = UITextField(frame: CGRect(x: 0, y: 0, width: cell.contentView.frame.width, height: cell.contentView.frame.height))
                cell.hiddenTextField = textField

                let datePicker = UIDatePicker()
                datePicker.datePickerMode = .time
                datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
                textField.inputView = datePicker
                textField.isHidden = true

                let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
                let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
                let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                toolBar.items = [cancelButton, flexibleSpace, doneButton]
                textField.inputAccessoryView = toolBar

                cell.contentView.addSubview(textField)
            }
            let isPasswordSet = UserDefaults.standard.bool(forKey: "isPasswordSet")
            let isNotificationSet = UserDefaults.standard.bool(forKey: "isNotificationSet")

            let switchView = UISwitch(frame: .zero)

            switchView.tag = indexPath.row
            if switchView.tag == 0 {
                switchView.isOn = isPasswordSet
            } else if switchView.tag == 1 {
                switchView.isOn = isNotificationSet
            }
            switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell.switchButton = switchView
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        }

        cell.iconView.image = UIImage(systemName: profileConfig.imageArray[indexPath.row])
        cell.titleLabel.text = profileConfig.titleArray[indexPath.row]
        cell.descriptionLabel.text = profileConfig.descriptionArray[indexPath.row]

        return cell
    }

}

// MARK: - Function

extension ProfileViewController {

    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)

        let indexPath = IndexPath(row: 1, section: 0)

        guard let cell = tableView.cellForRow(at: indexPath) as? ProfileTableViewCell else { return }

        cell.switchButton?.setOn(false, animated: true)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
        UserDefaults.standard.set(false, forKey: "isNotificationSet")
    }

    @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
        let indexPath = IndexPath(row: 1, section: 0)

        guard let cell = tableView.cellForRow(at: indexPath) as? ProfileTableViewCell else { return }

        self.view.endEditing(true)

        guard let datePicker = cell.hiddenTextField?.inputView as? UIDatePicker else { return }

        let selectedTime = datePicker.date
        UserDefaults.standard.set(selectedTime, forKey: "notificationTime")
        UserDefaults.standard.set(true, forKey: "isNotificationSet")
        createNotification(selectedTime: selectedTime)
    }

    @objc func switchChanged(_ sender: UISwitch) {
        if sender.tag == 0 {
            if sender.isOn {
                let currentMode = PasswordSet.on
                let viewModel = SettingPasswordViewModel(mode: currentMode)

                let settingPasswordVC = SettingPasswordViewController(viewModel: viewModel)
                settingPasswordVC.modalPresentationStyle = .overFullScreen
                self.present(settingPasswordVC, animated: true, completion: nil)
            } else {
                let currentMode = PasswordSet.off
                UserDefaults.standard.set(false, forKey: "isPasswordSet")
            }
        }

        if sender.tag == 1 {

            let indexPath = IndexPath(row: 1, section: 0)

            guard let cell = tableView.cellForRow(at: indexPath) as? ProfileTableViewCell else { return }

            if sender.isOn {
                cell.hiddenTextField?.becomeFirstResponder()
            } else {
                UserDefaults.standard.set(false, forKey: "isNotificationSet")
                cell.hiddenTextField?.resignFirstResponder()
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
            }

        }
    }

    func createNotification(selectedTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Conscious"
        content.body = "今天寫日記了嗎？"
        content.sound = UNNotificationSound.default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

// TODO: Refractor / datePicker 彈出很慢 改善效能
