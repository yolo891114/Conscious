//
//  NewDiaryViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/12.
//

import UIKit

class NewDiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet var imageButtons: [UIButton]!
    @IBOutlet weak var submitButton: UIButton!

    var viewModel = NewDiaryViewModel()

    var isSelectedPhoto = false // 判定是否有選擇照片

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        if let editTitle = viewModel.diaryToEdit?.title,
           let editContent = viewModel.diaryToEdit?.content {
            titleTextField.text = editTitle
            contentTextField.text = editContent
        }

    }

    @IBAction func imageButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        isSelectedPhoto = true
        if let image = info[.originalImage] as? UIImage {
            let imageToSet = image.withRenderingMode(.alwaysOriginal)
            imageButtons[0].setImage(imageToSet, for: .normal)
        }

        dismiss(animated: true, completion: nil)
    }

    @objc func submitButtonTapped() {

        viewModel.title = titleTextField.text ?? ""
        viewModel.content = contentTextField.text ?? ""
        viewModel.photoData = imageButtons[0].imageView?.image?.jpegData(compressionQuality: 0.8)
//        for button in imageButtons {
//            viewModel.photoData = button.imageView?.image?.jpegData(compressionQuality: 0.8)
//        }
        viewModel.saveDiary()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
