//
//  ProfileTableViewCell.swift
//  Conscious
//
//  Created by jeff on 2023/10/1.
//

import Foundation
import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    var hiddenTextField: UITextField?
    var switchButton: UISwitch?
}
