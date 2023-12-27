//
//  ConsciousTests.swift
//  ConsciousTests
//
//  Created by jeff on 2023/10/23.
//

import Combine
@testable import Conscious
import XCTest

class MockDiaryProvider: DiaryProvider {
    var diariesToReturn: [Diary] = []

    override func fetchDiaries() -> Future<[Diary], Error> {
        return Future { promise in
            promise(.success(self.diariesToReturn))
        }
    }
}

final class ConsciousTests: XCTestCase {
    var sut: TimelineViewModel!
    var mockProvider: MockDiaryProvider!

    var cancellables = Set<AnyCancellable>()

    let dateFormatter = DateFormatter()

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockProvider = MockDiaryProvider()
        sut = TimelineViewModel(model: mockProvider)
    }

    override func tearDownWithError() throws {
        mockProvider = nil
        sut = nil
        try super.tearDownWithError()
    }

    // 測試 Combine 框架觀察的 diaries 變數在 fetch 後有正確被更新
    func testFetchDiariesUpdatesDiaries() {
        let expectation = XCTestExpectation(description: "Diaries are fetched")

        let diary = Diary(diaryID: "01", date: Date(), title: "Test1", content: "Content1", photoCollection: [])

        mockProvider.diariesToReturn = [diary]

        sut.$diaries
            .sink { receivedDiaries in
                if !receivedDiaries.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.fetchDiaries()

        wait(for: [expectation], timeout: 3.0)
    }

    // 測試日記有正確按照時間分組
    func testSortedByDate() {
        // 假資料
        let date1 = Date()
        let date2 = Calendar.current.date(byAdding: .day, value: -1, to: date1)!
        let date3 = Calendar.current.date(byAdding: .day, value: +1, to: date1)!

        let diary1 = Diary(diaryID: "01", date: date1, title: "Test1", content: "Content1", photoCollection: [])
        let diary2 = Diary(diaryID: "02", date: date2, title: "Test2", content: "Content2", photoCollection: [])
        let diary3 = Diary(diaryID: "03", date: date3, title: "Test3", content: "Content3", photoCollection: [])

        mockProvider.diariesToReturn = [diary1, diary2, diary3]

        sut.fetchDiaries()

        dateFormatter.dateFormat = "yyyy-MM-dd"

        let expectedDiariesByDate = [
            dateFormatter.string(from: date3): [diary3],
            dateFormatter.string(from: date1): [diary1],
            dateFormatter.string(from: date2): [diary2],
        ]

        XCTAssertEqual(sut.diariesByDate, expectedDiariesByDate)
    }

    // 測試日期有正確被格式化
    func testDateFormatting() {
        let inputDate = Date()
        print("inputDate:\(inputDate)")

        dateFormatter.dateFormat = "yyyy-MM-dd"

        let expectedOutput = "2023-10-23"

        let actualOutput = dateFormatter.string(from: inputDate)

        XCTAssertEqual(expectedOutput, actualOutput, "Date formatting failed.")
    }
}
