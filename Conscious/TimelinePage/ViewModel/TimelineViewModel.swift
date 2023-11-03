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
    @Published var sortedDates: [String] = []

    let dateFormatter = DateFormatter()

    private var cancellables = Set<AnyCancellable>()

    private let model: DiaryProvider

    init(model: DiaryProvider) {
        self.model = model
    }

    // Fetch 後回傳 Future promise
    func fetchDiaries() {
        model.fetchDiaries()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            },
                  receiveValue: { [weak self] dairy in
                guard let self = self else { return }
                self.diaries = dairy
                self.dateFormatter.dateFormat = "yyyy-MM-dd"
                self.diariesByDate = Dictionary(grouping: diaries) { self.dateFormatter.string(from: $0.timestamp) }

                self.sortedDates = Array(self.diariesByDate.keys).sorted(by: >)

                // 使用 sortedDates 來重新設置 diariesByDate
                self.diariesByDate = self.sortedDates.reduce(into: [String: [Diary]]()) { (result, date) in
                    result[date] = self.diariesByDate[date]
                }
            })
            .store(in: &cancellables)
    }

}
