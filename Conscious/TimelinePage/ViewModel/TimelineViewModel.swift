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

    private var cancellables = Set<AnyCancellable>()

    // Fetch 後回傳 Future promise
    func fetchDiaries() -> Future<[Diary], Error> {
        return Future { promise in
            FirebaseManager.shared.fetchAllDiaries { diaries, error in
                if let error = error {
                    print("Error fetching diaries: \(error.localizedDescription)")
                    promise(.failure(error))
                }

                if let diaries = diaries {
                    self.diaries = diaries
                    promise(.success(diaries))
                }
            }
        }

    }

}
