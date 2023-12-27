//
//  DiaryProvider.swift
//  Conscious
//
//  Created by jeff on 2023/10/20.
//

import Combine
import Foundation

class DiaryProvider {
    func fetchDiaries() -> Future<[Diary], Error> {
        return Future { promise in
            FirebaseManager.shared.fetchAllDiaries { diaries, error in
                if let error = error {
                    print("Error fetching diaries: \(error.localizedDescription)")
                    promise(.failure(error))
                }
                if let diaries = diaries {
                    promise(.success(diaries))
                }
            }
        }
    }
}
