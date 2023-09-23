//
//  TimelineViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Foundation
import Combine

class TimelineViewModel: ObservableObject {

    @Published var diaries: [Diary] = []
    @Published var diariesByDate: [String: [Diary]] = [:]

    private var cancellables = Set<AnyCancellable>()

    let dateFormatter = DateFormatter()

    // Fetch 後回傳 Future promise
    func fetchDiaries() -> Future<[Diary], Error> {
        return Future { promise in
            FirebaseManager.shared.fetchAllDiaries { diaries, error in
                if let error = error {
                    print("Error fetching diaries: \(error.localizedDescription)")
                    promise(.failure(error))
                }

                if let diaries = diaries {
                    self.dateFormatter.dateFormat = "yyyy-MM-dd"
                    self.diaries = diaries
                    self.diariesByDate = Dictionary(grouping: diaries) { self.dateFormatter.string(from: $0.timestamp) }
                    promise(.success(diaries))
                }
            }
        }

    }

}
