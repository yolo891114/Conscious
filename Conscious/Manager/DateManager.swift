//
//  DateManager.swift
//  Conscious
//
//  Created by jeff on 2023/9/19.
//

import Foundation

class DateManager {
    
    static let shared = DateManager()
    
    lazy var isoCalendar = Calendar(identifier: .iso8601) // 西曆
    lazy var lunarCalendar = Calendar(identifier: .chinese) // 農曆
    
    // 轉農曆之 Formatter
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.calendar = lunarCalendar
        formatter.dateFormat = "dd"
        return formatter
    }()
    
    lazy var isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        return formatter
    }()
    
    private init() {}

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

    func getCurrentDay() -> Int {
        isoCalendar.component(.day, from: Date())
    }
    
    func getCurrentMonth() -> Int {
        isoCalendar.component(.month, from: Date())
    }

    func getCurrentYear() -> Int {
        isoCalendar.component(.year, from: Date())
    }
    
    func getWeekday(date: Date) -> Int {
        isoCalendar.component(.weekday, from: date)
    }
//    
//    func convertStringToISODate(date: String) -> Date? {
//
//    }
    
    // 計算需要多少空白
    func getSpacingDay(year: Int, month: Int) -> Int {
        
        let dateComponent = DateComponents(year: year, month: month)
        guard let date = isoCalendar.date(from: dateComponent) else { return 0 }
        let weekday = getWeekday(date: date)
        return weekday - 1
    }
    
    func getLunarDayString(year: Int, month: Int, day: Int) -> String {
        let dateComponent = DateComponents(year: year, month: month, day: day)
        guard let date = isoCalendar.date(from: dateComponent) else { return "" }
        
        return formatter.string(from: date)
    }
    
    func getDaysInMonth(year: Int, month: Int) -> Int {
        let dateComponent = DateComponents(year: year, month: month)
        guard let date = isoCalendar.date(from: dateComponent) else { return 0 }
        guard let range = isoCalendar.range(of: .day, in: .month, for: date) else { return 0 }
        return range.count
    }
    
    // compareTwoDateIsSame
    func compareDateIsToday(date: Date, today: Date = Date()) -> Bool {
        let currentYear = getCurrentYear()
        let currentMonth = getCurrentMonth()
        let currentDay = getCurrentDay()
        
        let dateComponent = DateComponents(year: currentYear, month: currentMonth, day: currentDay)
        let todayDate = isoCalendar.date(from: dateComponent)
        
        if date == todayDate {
            return true
        } else {
            return false
        }
    }
    
    func getDateFrom(date: String) -> Date? {
        isoFormatter.date(from: date)
    }
}
