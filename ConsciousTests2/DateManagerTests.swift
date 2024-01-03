//
//  DateManagerTests.swift
//  ConsciousTests2
//
//  Created by Wendy_Sung on 2024/1/2.
//

@testable import Conscious
import XCTest

final class DateManagerTests: XCTestCase {
    var dateManager: DateManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dateManager = DateManager.shared
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }

    func testConvertToWeekDay() {
        let inputDate = Date(timeIntervalSince1970: 1_704_178_947)
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

    func testTwoDateIsSameDay() {
        // 2024/01/02 00:00:00
        let date1 = Date(timeIntervalSince1970: 1_704_124_800)
        // 2024/01/02 08:00:00
        let date2 = Date(timeIntervalSince1970: 1_704_153_600)

        let output = dateManager.compareTwoDateIsSame(date1: date1, date2: date2)
        let answer = true
        XCTAssertEqual(output, answer)
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

        let output = dateManager.getDateFrom(year: year, month: month, day: day)
        let dateComponent = DateComponents(year: year, month: month, day: day)

        guard let answerDate = Calendar(identifier: .iso8601).date(from: dateComponent) else { return }

        XCTAssertEqual(output, answerDate)
    }

    func testInvalidComponentIntToDate() {
        /// input Date component 2024/2/30
        let answer: Date? = nil

        let year1 = 2024
        let month1 = 02
        let day1 = 30

        let output1 = dateManager.getDateFrom(year: year1, month: month1, day: day1)
        XCTAssertEqual(output1, answer)
        /// input Date component 2024/4/31
        let year2 = 2024
        let month2 = 04
        let day2 = 31

        let output2 = dateManager.getDateFrom(year: year2, month: month2, day: day2)
        XCTAssertEqual(output2, answer)
        /// input Date component 2024/7/32
        let year3 = 2024
        let month3 = 07
        let day3 = 32

        let output3 = dateManager.getDateFrom(year: year3, month: month3, day: day3)
        XCTAssertEqual(output3, answer)
        /// input Date component 2024/13/1
        let year4 = 2024
        let month4 = 13
        let day4 = 01

        let output4 = dateManager.getDateFrom(year: year4, month: month4, day: day4)
        XCTAssertEqual(output4, answer)
    }
}
