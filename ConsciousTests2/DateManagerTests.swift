//
//  DateManagerTests.swift
//  ConsciousTests2
//
//  Created by Wendy_Sung on 2024/1/2.
//

import XCTest
@testable import Conscious

final class DateManagerTests: XCTestCase {
    
    var dateManager: DateManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.dateManager = DateManager.shared
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }
    
    func testConvertToWeekDay() {
        let inputDate = Date(timeIntervalSince1970: 1704178947)
        let outputWeekday = dateManager.getWeekday(date: inputDate)
        let answerWeekday = 3
        
        XCTAssertEqual(outputWeekday, answerWeekday)
    }
    
    func testGetSpacingDay() {
        let year = 2024
        let month = 1
        let answer = 1
        
        let output = dateManager.getSpacingDay(year: year, month: month)
        XCTAssertEqual(output, answer)
    }
    
    func testLunarDayString() {
        /// input Date of 2024/1/2 -> 廿一
        let year = 2024
        let month = 1
        let day = 2
        
        let output = dateManager.getLunarDayString(year: year, month: month, day: day)
        let answer = "廿一"
        XCTAssertEqual(output, answer)
    }
    
    // testTwoDateIsSameDay
    func testDateIsToday() {
        /// input Date of 2024/1/2 -> Bool
        let year = 2024
        let month = 1
        let day = 2
        
        let dateComponent = DateComponents(year: year, month: month, day: day)
        guard let date = Calendar(identifier: .iso8601).date(from: dateComponent) else { return }
        let output = dateManager.compareDateIsToday(date: date)
        let answer = true
        XCTAssertEqual(output, answer)
    }
    
    func testIfIAmWritingUnitTesting() {
        let year = 2024
        let month = 1
        let day = 2
        
        let today = DateComponents(year: year, month: month, day: day)
        
        let dateComponent = DateComponents(year: year, month: month, day: day)
        guard let date = Calendar(identifier: .iso8601).date(from: dateComponent) else { return }
//        let output = dateManager.compareDateIsToday(date: date, today: today)
    }
    
    func testIfIAmWritingProject() {
        let year = 2024
        let month = 1
        let day = 2
        
        let dateComponent = DateComponents(year: year, month: month, day: day)
        guard let date = Calendar(identifier: .iso8601).date(from: dateComponent) else { return }
        let output = dateManager.compareDateIsToday(date: date)
        XCTAssertEqual(output, true)
    }
    
    func testTotalDayInMonth() {
        /// input Date of 2024/1 -> Int
        let year = 2024
        let month = 1
        
        let output = dateManager.getDaysInMonth(year: year, month: month)
        let answer = 31
        XCTAssertEqual(output, answer)
    }
    
    func testValidComponentIntToDate() {
        /// input Date component 2024/1/2 -> Date
        let year = 2024
        let month = 1
        let day = 2
        let date = "\(year)-\(month)-\(day)"
        
        let output = dateManager.getDateFrom(date: date)
        let dateComponent = DateComponents(year: year, month: month, day: day)
    
        guard let answerDate = Calendar(identifier: .iso8601).date(from: dateComponent) else { return }

        XCTAssertEqual(output, answerDate)
    }
    
    func testInvalidComponentIntToDate() {
        /// input Date component 2024/2/30
        let answer: Date? = nil

        let year1 = 2024
        let month1 = 2
        let day1 = 30
        let date1 = "\(year1)-\(month1)-\(day1)"
        
        let output1 = dateManager.getDateFrom(date: date1)
        XCTAssertEqual(output1, answer)
       /// input Date component 2024/4/31
        ///
        /// input Date component 2024/7/32
        ///
        /// input Date component 2024/13/1
        let year4 = 2024
        let month4 = 13
        let day4 = 1
        let date4 = "\(year4)-\(month4)-\(day4)"
        
        let output4 = dateManager.getDateFrom(date: date4)
        XCTAssertEqual(output4, answer)
    }
}
