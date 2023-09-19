//
//  EmotionSurveyViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import UIKit

class EmotionSurveyViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    lazy var viewModel = EmotionSurveyViewModel()

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let totalScore = viewModel.calculateTotalScore()
        let newEmotionRecord = EmotionRecord(id: UUID().uuidString,
                                             emotionScore: totalScore,
                                             date: Date())
        FirebaseManager.shared.saveEmotionRecord(to: "no1", emotionRecord: newEmotionRecord)
        print("Total score is: \(totalScore)")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResultSegue", let destinationVC = segue.destination as? FinishSurveyViewController {
            destinationVC.totalScore = viewModel.calculateTotalScore()
        }
    }
}

extension EmotionSurveyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmotionSurveyTableViewCell") as? EmotionSurveyTableViewCell else { return UITableViewCell() }

        cell.question = viewModel.questions[indexPath.row]
        // 將傳送過來的 sender.tag 作為分數計算
        cell.passScoreData = { [weak self] score in
            self?.viewModel.updateScore(forQuestionAt: indexPath.row, withScore: score)
        }

        return cell
    }

}
