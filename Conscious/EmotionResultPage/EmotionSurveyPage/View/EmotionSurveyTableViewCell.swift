//
//  EmotionSurveyTableViewCell.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import UIKit

class EmotionSurveyTableViewCell: UITableViewCell {

    @IBOutlet var answerButtons: [UIButton]!

    @IBOutlet weak var questionLabel: UILabel!

    var question: Question? {
            didSet {
                questionLabel.text = question?.caption
            }
        }

    var passScoreData: ((Int) -> Void)?

    @IBAction func answerButtonsTapped(_ sender: UIButton) {
        for button in answerButtons {
            if button == sender {
                button.isSelected = true
                passScoreData?(sender.tag)
            } else {
                button.isSelected = false
            }
        }
    }

    func updateUI(with score: Int?) {
        for button in answerButtons {
            if let score = score {
                button.isSelected = (button.tag == score)
            } else {
                button.isSelected = false
            }
        }
    }
}
