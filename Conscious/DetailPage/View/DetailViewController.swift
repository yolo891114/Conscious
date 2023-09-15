//
//  DetailPageViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/15.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var diary: Diary?

    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = diary?.timestamp.description
        titleLabel.text = diary?.title
        contentLabel.text = diary?.content
    }
}
