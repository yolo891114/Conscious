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

    // 新增打卡記錄
    func addPunchRecord(to userID: String, punchDate: Date, continuousDay: Int, highestDay: Int) {

        // 找到特定用戶
        let userRef = db.collection("users").document(userID)

        let punchRecordsRef = userRef.collection("PunchRecords")

        punchRecordsRef.addDocument(data: [
            "punchDate": punchDate,
            "continuousDay": continuousDay,
            "highestDay": highestDay
        ])
    }
}
