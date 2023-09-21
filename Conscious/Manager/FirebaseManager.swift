//
//  FirebaseManager.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {

    static let shared = FirebaseManager()

    let db = Firestore.firestore()

    // 註冊
    func signUp(userID: String, email: String, nickname: String, password: String) {

        let userRef = db.collection("users").document(userID)

        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                print("User created successfully")

                userRef.setData([
                    "userID": userID,
                    "email": email,
                    "nickname": nickname
                ])
            }
        }
    }

    // 新增日記
    func addNewDiary(user userID: String, diary: Diary) {
        let userRef = db.collection("users").document(userID)
        let diaryRef = userRef.collection("diaries").document(diary.diaryID)

        var photoCollectionArray: [[String: Any]] = []
            for photo in diary.photoCollection {
                let photoDict: [String: Any] = [
                    "url": photo.url,
                    "description": photo.description,
                    "photoID": photo.photoID
                ]
                photoCollectionArray.append(photoDict)
            }

        diaryRef.setData([
            "diaryID": diary.diaryID,
            "date": diary.timestamp,
            "title": diary.title,
            "content": diary.content,
            "photoCollection": photoCollectionArray
        ])
    }

    // 拿到所有日記
    func fetchAllDiaries(user userID: String, completion: @escaping ([Diary]?, Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        let diaryRef = userRef.collection("diaries")

        diaryRef.order(by: "date", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all diaries: \(error.localizedDescription)")
            }

            if let documents = snapshot?.documents {
                let diaries = documents.compactMap { Diary(data: $0.data()) }
                completion(diaries, nil)
            }
        }
    }

    // 更新日記
    func updateDiary(user userID: String, diary: Diary) {
        let userRef = db.collection("users").document(userID)
        let diaryRef = userRef.collection("diaries").document(diary.diaryID)

        var photoCollectionArray: [[String: Any]] = []
        for photo in diary.photoCollection {
            let photoDict: [String: Any] = [
                "url": photo.url,
                "description": photo.description,
                "photoID": photo.photoID
            ]
            photoCollectionArray.append(photoDict)
        }

        diaryRef.updateData([
            "title": diary.title,
            "content": diary.content,
            "photoCollection": photoCollectionArray
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    // 刪除日記
    func deleteDiary(user userID: String, diaryID: String) {
        let userRef = db.collection("users").document(userID)
        let diaryRef = userRef.collection("diaries").document(diaryID)

        diaryRef.delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}

// MARK: - Emotion Record

extension FirebaseManager {

    func saveEmotionRecord(to userID: String, emotionRecord: EmotionRecord) {

        // 找到特定用戶
        let userRef = db.collection("users").document(userID)

        let emotionRecordRef = userRef.collection("emotionRecords").document(emotionRecord.id.uuidString)

        emotionRecordRef.setData([
            "id": emotionRecord.id.uuidString,
            "emotionScore": emotionRecord.emotionScore,
            "date": emotionRecord.date
        ])
    }

    func deleteCurrentWeekEmotionRecord(user userID: String) {
        let userRef = db.collection("users").document(userID)
        let emotionRecordRef = userRef.collection("emotionRecords")

        let (startOfWeek, endOfWeek) = DateManager.shared.getCurrentWeekDates()

        let period = emotionRecordRef.whereField("date", isGreaterThanOrEqualTo: startOfWeek)
                                     .whereField("date", isLessThanOrEqualTo: endOfWeek)

        period.getDocuments { snapshot, error in
            if let error = error {
                print("Error when get this week's document: \(error)")
            }

            if let documents = snapshot?.documents {
                for document in documents {
                    emotionRecordRef.document(document.documentID).delete { error in
                        if let error = error {
                            print("Error when delete this week's document: \(error)")
                        }
                    }
                }
            }
        }
    }

    func fetchEmotionRecords(user userID: String, completion: @escaping ([EmotionRecord]?, Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        let emotionRecordRef = userRef.collection("emotionRecords")

        emotionRecordRef.order(by: "date", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all emotion records: \(error.localizedDescription)")
            }

            if let documents = snapshot?.documents {
                let records = documents.compactMap { EmotionRecord(data: $0.data()) }
                completion(records, nil)
            }
        }
    }

    func canAddRecordThisWeek(user userID: String, completion: @escaping (Bool) -> Void) {
        let (startOfWeek, endOfWeek) = DateManager.shared.getCurrentWeekDates()

        let userRef = db.collection("users").document(userID)
        let emotionRecordRef = userRef.collection("emotionRecords")

        let period = emotionRecordRef.whereField("date", isGreaterThanOrEqualTo: startOfWeek)
                                     .whereField("date", isLessThanOrEqualTo: endOfWeek)

        period.getDocuments { snapshot, error in
            if let error = error {
                print("Error when get this week's document: \(error)")
                completion(false)
                return
            }

            if let documents = snapshot?.documents, !documents.isEmpty {
                // 本週已有資料
                print("本週有資料：\(documents)")
                completion(false)
            } else {
                // 本週尚無資料
                print("本週無資料")
                completion(true)
            }
        }
    }

}

// MARK: - Punch Record

extension FirebaseManager {

    // 新增打卡記錄
    func addPunchRecord(to userID: String, punchRecord: PunchRecord) {

        let userRef = db.collection("users").document(userID)
        let punchRecordsRef = userRef.collection("PunchRecords").document(punchRecord.punchID)

        punchRecordsRef.setData([
            "punchID": punchRecord.punchID,
            "punchDate": punchRecord.punchDate,
            "consecutiveDays": punchRecord.consecutiveDays,
            "highestDay": punchRecord.highestDay
        ])
    }

    func fetchPunchRecord(userID: String, completion: @escaping ([PunchRecord]?, Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        let punchRecordRef = userRef.collection("PunchRecords")

        punchRecordRef.order(by: "punchDate", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all emotion records: \(error.localizedDescription)")
            }

            if let documents = snapshot?.documents {
                let records = documents.compactMap { PunchRecord(data: $0.data()) }
                completion(records, nil)
            }
        }
    }

    func deletePunchRecord(userID: String, punchID: String) {
        let userRef = db.collection("users").document(userID)
        let punchRecordsRef = userRef.collection("PunchRecords").document(punchID)

        punchRecordsRef.delete { error in
            if let error = error {
                print("Error removing punch record: \(error)")
            } else {
                print("Punch record successfully removed!")
            }
        }
    }
}
