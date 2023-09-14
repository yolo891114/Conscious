//
//  NewDiaryViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/12.
//

import UIKit

class NewDiaryViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet var imageButtons: [UIButton]!
    @IBOutlet weak var submitButton: UIButton!
    
    var viewModel = NewDiaryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    @objc func submitButtonTapped() {
        viewModel.title = titleTextField.text ?? ""
        viewModel.content = contentTextField.text ?? ""
        viewModel.saveDiary()
    }
}
