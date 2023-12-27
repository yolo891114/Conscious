//
//  DetailViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/15.
//

import Foundation
import Kingfisher
import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var imageView: UIImageView!

    var diary: Diary?

    @IBAction func editButtonTapped(_: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newDiaryViewController = storyboard.instantiateViewController(withIdentifier: "NewDiaryViewController") as? NewDiaryViewController {
            newDiaryViewController.viewModel.diaryToEdit = diary
            navigationController?.pushViewController(newDiaryViewController, animated: true)
        }
    }

    @IBAction func deleteButtonTapped(_: UIButton) {
        if let diaryID = diary?.diaryID {
            FirebaseManager.shared.deleteDiary(diaryID: diaryID)
            navigationController?.popToRootViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = diary?.timestamp.description
        titleLabel.text = diary?.title
        contentLabel.text = diary?.content
        if let urlString = diary?.photoCollection.first?.url,
           let url = URL(string: urlString)
        {
            imageView.kf.setImage(with: url)
        }
    }
}
