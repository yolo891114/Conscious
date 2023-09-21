//
//  DetailPageViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/15.
//

import Foundation
import UIKit
import Kingfisher

class DetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var diary: Diary?

    @IBAction func editButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newDiaryViewController = storyboard.instantiateViewController(withIdentifier: "NewDiaryViewController") as? NewDiaryViewController {
            newDiaryViewController.viewModel.diaryToEdit = self.diary
            self.navigationController?.pushViewController(newDiaryViewController, animated: true)
        }
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let diaryID = diary?.diaryID {
            FirebaseManager.shared.deleteDiary(user: "no1", diaryID: diaryID)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = diary?.timestamp.description
        titleLabel.text = diary?.title
        contentLabel.text = diary?.content
        if let urlString = diary?.photoCollection.first?.url,
           let url = URL(string: urlString) {
            self.imageView.kf.setImage(with: url)
        }
    }
}
