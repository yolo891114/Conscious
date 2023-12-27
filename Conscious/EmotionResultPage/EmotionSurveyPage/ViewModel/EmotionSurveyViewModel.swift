//
//  EmotionSurveyViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Combine
import Foundation
import SwiftUI

class EmotionSurveyViewModel: ObservableObject {
    @Published var questions: [Question] = [
        Question(caption: "Do you feel tired for no reason?"),
        Question(caption: "Do you feel tense?"),
        Question(caption: "Are you so tense that you can't calm down?"),
        Question(caption: "Do you feel helpless?"),
        Question(caption: "Do you feel restless or agitated?"),
        Question(caption: "Are you so restless that you can't sit down?"),
        Question(caption: "Do you feel depressed?"),
        Question(caption: "Do you feel like everything is an effort?"),
        Question(caption: "Is there nothing that makes you happy?"),
        Question(caption: "Do you feel worthless?"),
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
        case 0 ..< 20:
            return "Your current psychological state seems quite stable; please continue to maintain mindfulness and self-care!"
        case 20 ... 24:
            return "Feeling occasional stress or unease in life is entirely normal; try to find activities that help you relax and focus."
        case 25 ... 29:
            return "You may be experiencing heavy emotions, but that doesn't mean you can't work on self-improvement. Small steps count, so consider making gradual changes to your mindset."
        default:
            return "You may be facing a tough time, but remember, you're not alone. You have the inner strength and resources to overcome, even if it doesn't feel like it now."
        }
    }
}
