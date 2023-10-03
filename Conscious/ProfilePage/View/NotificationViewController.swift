//
//  SettingNotificationViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController {

//    @IBOutlet weak var datePicker: UIDatePicker!
    var datePicker: UIDatePicker!
    var doneButton: UIButton!
    var cancelButton: UIButton!

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        let selectedTime = datePicker.date
        UserDefaults.standard.set(selectedTime, forKey: "notificationTime")
        createNotification(selectedTime: selectedTime)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(datePicker)

        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(doneButton)

        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            cancelButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16)
        ])

        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

    }

    @objc func doneTapped() {
            dismiss(animated: true, completion: nil)
        }

        @objc func cancelTapped() {
            dismiss(animated: true, completion: nil)
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
