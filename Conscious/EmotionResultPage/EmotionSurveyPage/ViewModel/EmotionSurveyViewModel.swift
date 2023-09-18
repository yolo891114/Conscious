//
//  EmotionSurveyViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import Combine
import SwiftUI

class EmotionSurveyViewModel: ObservableObject {

    @Published var questions: [Question] = [
        Question(caption: "無故感到疲倦？"),
        Question(caption: "感到緊張？"),
        Question(caption: "緊張得沒法平復？"),
        Question(caption: "感覺無助？"),
        Question(caption: "感到焦躁或坐立不安？"),
        Question(caption: "煩躁得不能坐下來？"),
        Question(caption: "感到抑鬱？"),
        Question(caption: "感到所有事都很費力？"),
        Question(caption: "沒有東西能讓你愉快？"),
        Question(caption: "覺得自己沒有價值？")
        ]

    func calculateTotalScore() -> Int {
            return questions.reduce(0) { $0 + $1.score! }
        }

    func updateScore(forQuestionAt index: Int, withScore score: Int) {
            questions[index].score = score
        }

    func getResultText(for score: Int?) -> String {
        guard let score = score else { return "" }

        switch score {
        case 0..<20:
            return "你目前的心理狀態似乎相當穩定，請繼續保持覺察和自我照顧吧！"
        case 20...24:
            return "生活中偶爾感到有些壓力或不安非常正常，試著找一些能讓你放鬆和專注的活動吧！"
        case 25...29:
            return "你可能感到情緒有些重重，這並不意味著你無法進行自我改善。小步驟也是前進，不妨一點一滴來改變你的心態。"
        default:
            return "你可能正經歷一段非常困難的時期，但請記住，你並不孤單。你有內在的力量和資源來面對這一切，即使現在可能不這麼覺得。"
        }
    }
}
