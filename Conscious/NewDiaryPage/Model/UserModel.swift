//
//  UserModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Foundation

struct User {
    var userID: String
    var email: String
    var nickname: String
    var diary: Diary
    var punchRecord: PunchRecord
    var emotionRecord: [EmotionRecord]
}

struct Diary {
    var diaryID: String
    var date: Date
    var title: String
    var content: String
    var photoCollection: [Photo]
}

struct Photo {
    var url: String
    var description: String
    var photoID: String
}

struct PunchRecord {
    var punchDate: Date
    var continuousDay: Int
    var highestDay: Int
}

struct EmotionRecord {
    var emotionScore: Int
    var emotionDate: Date
}
