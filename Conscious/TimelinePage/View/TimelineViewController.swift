//
//  TimelineViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Foundation
import UIKit
import Combine

class TimelineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // 當 diaries 有變化時 reloadData()
    lazy var viewModel = {
        let viewModel = TimelineViewModel()
        viewModel.$diaries
            .sink { [weak self] _ in
                print("reload")
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        return viewModel
    }()

    var cancellables = Set<AnyCancellable>()

    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "yyyy-MM-dd"

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 利用 Combine 的 Future 功能，當非同步的 API 執行完畢後 reload
        viewModel.fetchDiaries()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in
                    self.tableView.reloadData()
                }
            )
            .store(in: &cancellables)

    }
}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.diaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineWithDateTableViewCell") as? TimelineWithDateTableViewCell else { return UITableViewCell() }

        let diary = viewModel.diaries[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.contentLabel.text = diary.content
        cell.dateLabel.text = dateFormatter.string(from: diary.timestamp)

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedDiary = viewModel.diaries[indexPath.row]
            if segue.identifier == "showDetailSegue",
               let detailVC = segue.destination as? DetailViewController {
                detailVC.diary = selectedDiary
            }
        }
    }

}
