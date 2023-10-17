//
//  TimelineViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/14.
//

import Foundation
import UIKit
import Combine
import Kingfisher

class TimelineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var cancellables = Set<AnyCancellable>()

    // 當 diaries 有變化時 reloadData()
    lazy var viewModel = {
        let viewModel = TimelineViewModel()
        viewModel.$diaries
            .sink { [weak self] _ in
                print("reload")
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$diariesByDate
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$sortedDates
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        return viewModel
    }()

    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "yyyy-MM-dd"

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .B5

        self.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)

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

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sortedDates.count
        //        return viewModel.diar
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = viewModel.sortedDates[section]
        return viewModel.diariesByDate[date]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sortedDates[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let textCell = tableView.dequeueReusableCell(withIdentifier: "TimelineWithDateTableViewCell") as? TimelineWithDateTableViewCell else { return UITableViewCell() }
        guard let photoCell = tableView.dequeueReusableCell(withIdentifier: "TimelineWithPhotoTableViewCell") as? TimelineWithPhotoTableViewCell else { return UITableViewCell() }

        // 先過濾日期
        let date = viewModel.sortedDates[indexPath.section]
        // 再過濾當天的所有日記出來
        guard let diariesForDate = viewModel.diariesByDate[date] else { return UITableViewCell() }
        let diary = diariesForDate[indexPath.row]

        if diary.photoCollection.isEmpty {

            textCell.titleLabel.text = diary.title
            textCell.contentLabel.text = diary.content

            return textCell
        } else {
            photoCell.titleLabel.text = diary.title
            photoCell.contentLabel.text = diary.content
            photoCell.diaryImage.kf.setImage(with: URL(string: diary.photoCollection[0].url))

            return photoCell
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let indexPath = tableView.indexPathForSelectedRow {
//            let selectedDiary = viewModel.diaries[indexPath.row]
//            if segue.identifier == "showDetailSegue",
//               let detailVC = segue.destination as? DetailViewController {
//                detailVC.diary = selectedDiary
//            }
//        }
//    }

}
