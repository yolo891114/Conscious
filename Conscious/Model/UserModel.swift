//
//  UserModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Foundation
import FirebaseFirestore

struct User {
    var userID: String
    var email: String
    var userName: String
    var diary: [Diary]
    var punchRecord: PunchRecord
    var emotionRecord: [EmotionRecord]
}

struct Diary: Equatable {
    var diaryID: String
    var timestamp: Date
    var title: String
    var content: String
    var photoCollection: [Photo]

    init(diaryID: String, date: Date, title: String, content: String, photoCollection: [Photo]) {
        self.diaryID = diaryID
        self.timestamp = date
        self.title = title
        self.content = content
        self.photoCollection = photoCollection
    }

    init?(data: [String: Any]) {
        guard let diaryID = data["diaryID"] as? String,
              let timestamp = data["date"] as? Timestamp,
              let title = data["title"] as? String,
              let content = data["content"] as? String else {
            return nil
        }

        self.diaryID = diaryID
        self.timestamp = timestamp.dateValue() // 轉換為 Date
        self.title = title
        self.content = content

        // photoCollection 可為空
        if let photoCollection = data["photoCollection"] as? [[String: Any]] {
            self.photoCollection = photoCollection.compactMap { (photoDict) -> Photo? in
                guard let url = photoDict["url"] as? String,
                      let description = photoDict["description"] as? String,
                      let photoID = photoDict["photoID"] as? String else {
                    return nil
                }
                return Photo(url: url, description: description, photoID: photoID)
            }
        } else {
            self.photoCollection = []
        }

    }

}

struct Photo: Equatable {
    var url: String
    var description: String
    var photoID: String
}

struct PunchRecord {
    var punchID: String
    var punchDate: Date
    var consecutiveDays: Int
    var highestDay: Int

    init(punchID: String, punchDate: Date,                                          consecutiveDays: Int, highestDay: Int) {
        self.punchID = punchID
        self.punchDate = punchDate
        self.consecutiveDays = consecutiveDays
        self.highestDay = highestDay
    }

    init?(data: [String: Any]) {
        guard let punchID = data["punchID"] as? String,
              let punchDate = data["punchDate"] as? Timestamp,
              let consecutiveDays = data["consecutiveDays"] as? Int,
              let highestDay = data["highestDay"] as? Int else {
                  print("Failed to initialize PunchRecord with data: \(data)")
                  return nil
        }

        self.punchID = punchID
        self.punchDate = punchDate.dateValue()
        self.consecutiveDays = consecutiveDays
        self.highestDay = highestDay
    }
}

struct EmotionRecord: Identifiable {
    var id = UUID()
    var emotionScore: Int
    var date: Date

    init(id: String, emotionScore: Int, date: Date) {
        self.id = UUID(uuidString: id) ?? UUID()
        self.emotionScore = emotionScore
        self.date = date
    }

    init?(data: [String: Any]) {
        guard let id = data["id"] as? String,
              let emotionScore = data["emotionScore"] as? Int,
              let date = data["date"] as? Timestamp else {
            print("Failed to initialize EmotionRecord with data: \(data)")
            return nil
        }

        self.id = UUID(uuidString: id) ?? UUID()
        self.emotionScore = emotionScore
        self.date = date.dateValue()
    }

}
