//
//  EmotionDataViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import Combine

enum DataScope {
    case month
    case year
}

class EmotionDataViewModel: ObservableObject {

    @Published var canAddNewRecord: Bool?
    @Published var dateChanged: Bool = false
    @Published var emotionRecords: [EmotionRecord] = []
    @Published var currentDataScope: DataScope = .month
    @Published var currentViewingMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var currentViewingYear: Int = Calendar.current.component(.year, from: Date())

    var filteredRecords: [EmotionRecord] {
        switch currentDataScope {
        case .month:
            print("month")
            return currentMonthRecords
        case .year:
            print("year")
            return currentYearRecords
        }
    }

    var currentViewingDateText: String {
        switch currentDataScope {
        case .month:
            return "\(currentViewingYear)-\(currentViewingMonth)"
        case .year:
            return "\(currentViewingYear)"
        }
    }

    private var cancellables = Set<AnyCancellable>()

    var currentMonthRecords: [EmotionRecord] {
        let calendar = Calendar.current
        return emotionRecords.filter {
            let recordMonth = calendar.component(.month, from: $0.date)
            let recordYear = calendar.component(.year, from: $0.date)

            return recordMonth == currentViewingMonth && recordYear == currentViewingYear
        }
    }

    var currentYearRecords: [EmotionRecord] {
        let calendar = Calendar.current
        return emotionRecords.filter {
            let recordYear = calendar.component(.year, from: $0.date)

            return recordYear == currentViewingYear
        }
    }
}

// MARK: - Function

extension EmotionDataViewModel {

    func canAddNewEmotionRecord() {
        FirebaseManager.shared.canAddRecordThisWeek(user: "no1") { canAddNewRecord in
            self.canAddNewRecord = canAddNewRecord
        }
    }

    func deleteCurrentWeekEmotionRecord() {
        FirebaseManager.shared.deleteCurrentWeekEmotionRecord(user: "no1")
        self.canAddNewRecord = true
    }

    func switchToPreviousPeriod() {
        if currentDataScope == .month {
            switchToPreviousMonth()
        } else {
            switchToPreviousYear()
        }
    }

    func switchToNextPeriod() {
        if currentDataScope == .month {
            switchToNextMonth()
        } else {
            switchToNextYear()
        }
    }

    func switchToPreviousMonth() {
        if currentViewingMonth > 1 {
            currentViewingMonth -= 1
        } else {
            currentViewingMonth = 12
            currentViewingYear -= 1
        }
        dateChanged.toggle()
    }

    func switchToNextMonth() {
        if currentViewingMonth < 12 {
            currentViewingMonth += 1
        } else {
            currentViewingMonth = 1
            currentViewingYear += 1
        }
        dateChanged.toggle()
    }

    func switchToPreviousYear() {
        currentViewingYear -= 1
        dateChanged.toggle()
    }

    func switchToNextYear() {
        currentViewingYear += 1
        dateChanged.toggle()
    }

    // Fetch 後回傳 Future promise
    func fetchEmotionRecords() -> Future<[EmotionRecord], Error> {
        return Future { promise in
            FirebaseManager.shared.fetchEmotionRecords(user: "no1") { emotionRecords, error in
                if let error = error {
                    print("Error fetching emotion record: \(error.localizedDescription)")
                    promise(.failure(error))
                }

                if let emotionRecords = emotionRecords {
                    self.emotionRecords = emotionRecords
                    promise(.success(emotionRecords))
                }
            }
        }
    }

}
