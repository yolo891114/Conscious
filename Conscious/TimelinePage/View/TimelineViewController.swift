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
        return viewModel.diariesByDate.keys.sorted(by: >).count
//        return viewModel.diar
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = Array(viewModel.diariesByDate.keys)[section]
        return viewModel.diariesByDate[date]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(viewModel.diariesByDate.keys.sorted(by: >))[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let textCell = tableView.dequeueReusableCell(withIdentifier: "TimelineWithDateTableViewCell") as? TimelineWithDateTableViewCell else { return UITableViewCell() }
        guard let photoCell = tableView.dequeueReusableCell(withIdentifier: "TimelineWithPhotoTableViewCell") as? PhotoTableViewCell else { return UITableViewCell() }

//        let date = Array(viewModel.diariesByDate.keys.sorted(by: >))[indexPath.section]
//        if let diary = viewModel.diariesByDate[date]?[indexPath.row] {
//                cell.titleLabel.text = diary.title
//                cell.contentLabel.text = diary.content
//            }
        let diary = viewModel.diaries[indexPath.row]

        if viewModel.diaries[indexPath.row].photoCollection.count == 0 {

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

extension TimelineViewController {

//    private func navigationBarConfiguration (_ controller: UINavigationController) {
//
//        if #available(iOS 13.0, *) {
//
//            let navBarAppearance = UINavigationBarAppearance()
//            navBarAppearance.configureWithOpaqueBackground()
//            navBarAppearance.backgroundColor = UIColor.B3
//            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//            navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//
//            controller.navigationBar.standardAppearance = navBarAppearance
//            controller.navigationBar.scrollEdgeAppearance = navBarAppearance
//            controller.navigationBar.tintColor = .white
//        } else {
//
//            controller.edgesForExtendedLayout = []
//            controller.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//            controller.navigationBar.tintColor = .white
//
//        }
//
//    }
}
