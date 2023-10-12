//
//  PhotoTableViewCell.swift
//  Conscious
//
//  Created by jeff on 2023/10/12.
//

import Foundation
import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var diaryImage: UIImageView!
    var deletePhoto: (() -> Void)?

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deletePhoto?()
    }

}
