//
//  EmotionResultModel.swift
//  Conscious
//
//  Created by jeff on 2023/10/20.
//

import Foundation
import Combine

class EmotionResultModel {

    func canAddNewEmotionRecord(completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.canAddRecordThisWeek { canAddNewRecord in
            if canAddNewRecord {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func deleteCurrentWeekEmotionRecord() {
        FirebaseManager.shared.deleteCurrentWeekEmotionRecord()
    }

    func fetchEmotionRecords(completion: @escaping ([EmotionRecord]?, Error?) -> Void) {
        FirebaseManager.shared.fetchEmotionRecords { records, error in
            if let error = error {
                completion(nil, error)
            }
            if let records = records {
                completion(records, nil)
            }
        }
    }
}
