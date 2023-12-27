//
//  FinishSurveyViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import UIKit

class FinishSurveyViewController: UIViewController {
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!

    var totalScore: Int?

    lazy var viewModel = EmotionSurveyViewModel()

    override func viewWillDisappear(_: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scoreLabel.text = "\(totalScore ?? 0)"
        resultLabel.text = viewModel.getResultText(for: totalScore)
    }

    @IBAction func finsihButtonTapped(_: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
