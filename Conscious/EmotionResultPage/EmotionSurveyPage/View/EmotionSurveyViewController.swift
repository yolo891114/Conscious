//
//  EmotionSurveyViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import UIKit

class EmotionSurveyViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    lazy var viewModel = EmotionSurveyViewModel()

    override func viewWillAppear(_: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func nextButtonTapped(_: UIButton) {
        let totalScore = viewModel.calculateTotalScore()
        let newEmotionRecord = EmotionRecord(id: UUID().uuidString,
                                             emotionScore: totalScore,
                                             date: Date())
        FirebaseManager.shared.saveEmotionRecord(emotionRecord: newEmotionRecord)
        print("Total score is: \(totalScore)")
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showResultSegue", let destinationVC = segue.destination as? FinishSurveyViewController {
            destinationVC.totalScore = viewModel.calculateTotalScore()
        }
    }
}

extension EmotionSurveyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmotionSurveyTableViewCell") as? EmotionSurveyTableViewCell else { return UITableViewCell() }

        let question = viewModel.questions[indexPath.row]
        cell.question = question

        cell.updateUI(with: question.score)

        // 將傳送過來的 sender.tag 作為分數計算
        cell.passScoreData = { [weak self] score in
            self?.viewModel.updateScore(forQuestionAt: indexPath.row, withScore: score)
        }

        return cell
    }
}
