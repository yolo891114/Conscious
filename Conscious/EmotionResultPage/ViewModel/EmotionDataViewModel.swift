//
//  EmotionDataViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import Combine

class EmotionDataViewModel: ObservableObject {

    @Published var canAddNewRecord: Bool?
    @Published var emotionRecords: [EmotionRecord] = []
    @Published var currentViewingMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var currentViewingYear: Int = Calendar.current.component(.year, from: Date())

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

    func switchToPreviousMonth() {
        if currentViewingMonth > 1 {
            currentViewingMonth -= 1
        } else {
            currentViewingMonth = 12
            currentViewingYear -= 1
        }
    }

    func switchToNextMonth() {
        if currentViewingMonth < 12 {
            currentViewingMonth += 1
        } else {
            currentViewingMonth = 1
            currentViewingYear += 1
        }
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
