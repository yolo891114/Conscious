//
//  StartSurveyViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Combine
import Foundation
import UIKit

class StartSurveyViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()

    var viewModel = StartSurveyViewModel()

    @IBAction func closeButtonTapped(_: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
