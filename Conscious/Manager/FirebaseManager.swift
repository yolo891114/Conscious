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

    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }

    // 註冊
    func signUp(email: String, userName: String, password: String, completion: @escaping ((Bool) -> Void)) {

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error creating user: \(error)")
                completion(false)
            }
            if let result = result {

                print("User created successfully")

                let userRef = self.db.collection("users").document(result.user.uid)

                userRef.setData([
                    "userID": result.user.uid,
                    "email": email,
                    "userName": userName
                ])

                self.authUpdate(user: result.user, name: userName)

                completion(true)
            }
        }
    }

    func authUpdate(user userData: FirebaseAuth.User, name userName: String) {
        let changeRequest = userData.createProfileChangeRequest()
        changeRequest.displayName = userName

        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating user profile: \(error.localizedDescription)")
            } else {
                print("User profile updated successfully.")
            }
        }
    }

    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error logging in: \(error)")
            }

            if let result = result {
                print("\(String(describing: result.user.displayName)) has logged in.")
            }
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }

    func resetPassword(email: String, completion: @escaping ((Bool) -> Void)) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // 新增日記
    func addNewDiary(diary: Diary) {
        guard let userID = getCurrentUserID() else { return }
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
    func fetchAllDiaries(completion: @escaping ([Diary]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else { return }

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
    func updateDiary(diary: Diary) {
        guard let userID = getCurrentUserID() else { return }
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
    func deleteDiary(diaryID: String) {

        guard let userID = getCurrentUserID() else { return }

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

    func saveEmotionRecord(emotionRecord: EmotionRecord) {

        guard let userID = getCurrentUserID() else { return }

        // 找到特定用戶
        let userRef = db.collection("users").document(userID)

        let emotionRecordRef = userRef.collection("emotionRecords").document(emotionRecord.id.uuidString)

        emotionRecordRef.setData([
            "id": emotionRecord.id.uuidString,
            "emotionScore": emotionRecord.emotionScore,
            "date": emotionRecord.date
        ])
    }

    func deleteCurrentWeekEmotionRecord() {

        guard let userID = getCurrentUserID() else { return }

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

    func fetchEmotionRecords(completion: @escaping ([EmotionRecord]?, Error?) -> Void) {

        guard let userID = getCurrentUserID() else { return }

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

    func canAddRecordThisWeek(completion: @escaping (Bool) -> Void) {

        guard let userID = getCurrentUserID() else { return }

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
    func addPunchRecord(punchRecord: PunchRecord) {

        guard let userID = getCurrentUserID() else { return }

        let userRef = db.collection("users").document(userID)
        let punchRecordsRef = userRef.collection("PunchRecords").document(punchRecord.punchID)

        punchRecordsRef.setData([
            "punchID": punchRecord.punchID,
            "punchDate": punchRecord.punchDate,
            "consecutiveDays": punchRecord.consecutiveDays,
            "highestDay": punchRecord.highestDay
        ])
    }

    func fetchPunchRecord(completion: @escaping ([PunchRecord]?, Error?) -> Void) {

        guard let userID = getCurrentUserID() else { return }

        let userRef = db.collection("users").document(userID)
        let punchRecordRef = userRef.collection("PunchRecords")

        punchRecordRef.order(by: "punchDate", descending: false).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all emotion records: \(error.localizedDescription)")
            }

            if let documents = snapshot?.documents {
                let records = documents.compactMap { PunchRecord(data: $0.data()) }
                completion(records, nil)
            }
        }
    }

    func deletePunchRecord(punchID: String) {

        guard let userID = getCurrentUserID() else { return }

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
