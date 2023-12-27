//
//  EmotionResultViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Combine
import Foundation
import UIKit

enum DataScope {
    case month
    case year
}

class EmotionResultViewModel: ObservableObject {
    @Published var canAddNewRecord: Bool?
    @Published var dateChanged: Bool = false
    @Published var emotionRecords: [EmotionRecord] = []
    @Published var dataScope: DataScope = .month

    private var currentMonth: Int = DateManager.shared.getCurrentMonth()
    private var currentYear: Int = DateManager.shared.getCurrentYear()

    private var model = EmotionResultProvider()
    private var cancellables = Set<AnyCancellable>()

    var filteredRecords: [EmotionRecord] {
        switch dataScope {
        case .month:
            return currentMonthRecords
        case .year:
            return currentYearRecords
        }
    }

    var dateString: String {
        switch dataScope {
        case .month:
            return "\(currentYear)-\(currentMonth)"
        case .year:
            return "\(currentYear)"
        }
    }

    var currentMonthRecords: [EmotionRecord] {
        let calendar = Calendar.current
        return emotionRecords.filter {
            let recordMonth = calendar.component(.month, from: $0.date)
            let recordYear = calendar.component(.year, from: $0.date)

            return recordMonth == currentMonth && recordYear == currentYear
        }
    }

    var currentYearRecords: [EmotionRecord] {
        let calendar = Calendar.current
        return emotionRecords.filter {
            let recordYear = calendar.component(.year, from: $0.date)

            return recordYear == currentYear
        }
    }
}

extension EmotionResultViewModel {
    // MARK: - Firebase

    func fetchEmotionRecords() {
        model.fetchEmotionRecords { [weak self] records, error in
            if let error = error {
                print("Error when fetching emotion records")
            }
            if let records = records {
                self?.emotionRecords = records
            }
        }
    }

    func checkIfCanAddNewRecord() {
        model.canAddNewEmotionRecord { [weak self] canAdd in
            self?.canAddNewRecord = canAdd
        }
    }

    func deleteCurrentWeekRecord() {
        model.deleteCurrentWeekEmotionRecord()
        canAddNewRecord = true
    }

    // MARK: - Caculate Period

    func switchToPreviousPeriod() {
        if dataScope == .month {
            switchToPreviousMonth()
        } else {
            switchToPreviousYear()
        }
    }

    func switchToNextPeriod() {
        if dataScope == .month {
            switchToNextMonth()
        } else {
            switchToNextYear()
        }
    }

    func switchToPreviousMonth() {
        if currentMonth > 1 {
            currentMonth -= 1
        } else {
            currentMonth = 12
            currentYear -= 1
        }
        dateChanged.toggle()
    }

    func switchToNextMonth() {
        if currentMonth < 12 {
            currentMonth += 1
        } else {
            currentMonth = 1
            currentYear += 1
        }
        dateChanged.toggle()
    }

    func switchToPreviousYear() {
        currentYear -= 1
        dateChanged.toggle()
    }

    func switchToNextYear() {
        currentYear += 1
        dateChanged.toggle()
    }
}
