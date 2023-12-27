//
//  NewDiaryViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Combine
import FirebaseFirestore
import FirebaseStorage
import Foundation

class NewDiaryViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var photoCollection: [Photo] = []
    @Published var photoData: Data?
    @Published var isPhotoSelected: Bool = false
    @Published var isLoading: Bool = false
    @Published var canSubmit: Bool = false

    private var cancellables = Set<AnyCancellable>()

    var isEditing: Bool = false

    // 修改日記
    // TODO: 修改時照片要讀取
    var diaryToEdit: Diary? {
        didSet {
            title = diaryToEdit?.title ?? ""
            content = diaryToEdit?.content ?? ""
            isEditing = true
        }
    }

    init() {
        Publishers.CombineLatest($title, $content)
            .map { title, content in
                !title.isEmpty && !content.isEmpty
            }
            .assign(to: &$canSubmit)
    }

    func calculateConsecutiveDay(dates: [Date]) -> (currentConsecutiveDay: Int, highestConsecutiveDay: Int) {
        if dates.isEmpty {
            return (1, 1)
        }

        var allDates = dates
        let today = Calendar.current.startOfDay(for: Date())

        let sortedDates = allDates.sorted(by: { $0 < $1 })
        var currentConsecutiveDay = 1
        var highestConsecutiveDay = 1

        // 檢查是不是今天第二篇
        if !allDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            allDates.append(today) // 添加今天的日期才能做比較
        }

        for date in 1 ..< sortedDates.count {
            let prevDate = Calendar.current.startOfDay(for: sortedDates[date - 1])
            let lastDate = Calendar.current.startOfDay(for: sortedDates[date])

            if let nextDayOfPrevDate = Calendar.current.date(byAdding: .day, value: 1, to: prevDate),
               Calendar.current.isDate(nextDayOfPrevDate, inSameDayAs: lastDate)
            {
                currentConsecutiveDay += 1
                if currentConsecutiveDay > highestConsecutiveDay {
                    highestConsecutiveDay = currentConsecutiveDay
                }
            } else {
                currentConsecutiveDay = 1
            }
        }

        return (currentConsecutiveDay, highestConsecutiveDay)
    }

    func saveDiary() {
        if isEditing {
            updateDiary()
        } else {
            if photoData != nil {
                uploadPhotos(imageData: photoData!) { url, photoID in
                    if let url = url, let photoID = photoID {
                        self.saveDiaryWithPhoto(url: url, photoID: photoID)
                        print("有照片")
                    } else {
                        print("照片上傳失敗，日記未保存。")
                    }
                }
            } else {
                saveDiaryWithPhoto(url: nil, photoID: nil)
                print("沒照片")
            }
        }
    }

    func updateDiary() {
        guard let diaryID = diaryToEdit?.diaryID,
              let date = diaryToEdit?.timestamp else { return }

        let updatedDiary = Diary(diaryID: diaryID,
                                 date: date,
                                 title: title,
                                 content: content,
                                 photoCollection: photoCollection)

        FirebaseManager.shared.updateDiary(diary: updatedDiary)
    }

    func saveDiaryWithPhoto(url: String?, photoID: String?) {
        FirebaseManager.shared.fetchPunchRecord { records, error in
            if let error = error {
                print("Error fetching all diaries: \(error.localizedDescription)")
            }

            guard let records = records else { return }

            let fetchedDates = records.map { $0.punchDate }

            print("fetchedDates: \(fetchedDates)")

            let (consecutiveDay, highestConsecutiveDay) = self.calculateConsecutiveDay(dates: fetchedDates)

            let newPunchRecord = PunchRecord(punchID: UUID().uuidString,
                                             punchDate: Date(),
                                             consecutiveDays: consecutiveDay,
                                             highestDay: highestConsecutiveDay)

            FirebaseManager.shared.addPunchRecord(punchRecord: newPunchRecord)
        }

        let newPhotoCollection = url != nil ? [Photo(url: url!, description: "", photoID: photoID ?? "")] : []
        let newDiary = Diary(diaryID: UUID().uuidString,
                             date: Date(),
                             title: title,
                             content: content,
                             photoCollection: newPhotoCollection)

        FirebaseManager.shared.addNewDiary(diary: newDiary)
    }

    // 當函數執行完畢後才執行 Closure
    func uploadPhotos(imageData: Data, completion: @escaping (_ url: String?, _ photoID: String?) -> Void) {
        let newPhotoID = UUID().uuidString

        let storage = Storage.storage()
        let imageRef = storage.reference().child("images/\(newPhotoID).jpg")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("上傳失敗: \(error)")
                completion(nil, nil)
                return
            }

            // 上傳成功後下載 URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("獲取URL失敗: \(error)")
                    completion(nil, nil)
                } else {
                    completion(url?.absoluteString, newPhotoID)
                }
            }
        }
    }
}
