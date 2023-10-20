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

    func getCurrentMonth() -> Int {
        let month = Calendar.current.component(.month, from: Date())
        return month
    }

    func getCurrentYear() -> Int {
        let year = Calendar.current.component(.year, from: Date())
        return year
    }
}
