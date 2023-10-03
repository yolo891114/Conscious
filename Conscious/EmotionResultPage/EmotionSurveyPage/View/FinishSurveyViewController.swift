//
//  FinishSurveyViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import UIKit

class FinishSurveyViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!

    var totalScore: Int?

    lazy var viewModel = EmotionSurveyViewModel()

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scoreLabel.text = "\(totalScore ?? 0)"
        resultLabel.text = viewModel.getResultText(for: totalScore)
    }

    @IBAction func finsihButtonTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
