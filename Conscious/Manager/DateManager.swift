//
//  DateManager.swift
//  Conscious
//
//  Created by jeff on 2023/9/19.
//

import Foundation

class DateManager {

    static let shared = DateManager()

    func getCurrentWeekDates() -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()

        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            fatalError("Cannot get start of week")
        }

        guard let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            fatalError("Cannot get end of week")
        }

        return (startOfWeek, endOfWeek)
    }
}
