//
//  SettingNotificationViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        let selectedTime = datePicker.date
        UserDefaults.standard.set(selectedTime, forKey: "notificationTime")
        createNotification(selectedTime: selectedTime)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
