//
//  NewDiaryViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/12.
//

import Combine
import NVActivityIndicatorView
import UIKit

class NewDiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var submitButton: UIButton!

    private let presentingIndicatorTypes = NVActivityIndicatorType.allCases.filter { $0 != .blank }

    var viewModel = NewDiaryViewModel()

    private var cancellables = Set<AnyCancellable>()

    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height

    let activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .ballScaleRipple, color: UIColor.B1)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.isLoading = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //        submitButton.setTitleColor(submitButton.titleColor(for: .normal), for: .disabled)

        tableView.delegate = self
        tableView.dataSource = self

        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        viewModel.$isPhotoSelected
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                DispatchQueue.main.async {
                    if isLoading {
                        self.activityIndicator.startAnimating()
                    } else {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.$canSubmit
            .sink { [weak self] canSubmit in
                self?.submitButton.isEnabled = canSubmit
                self?.submitButton.setTitleColor(canSubmit ? UIColor.B5 : UIColor.B5, for: .disabled)
                self?.submitButton.backgroundColor = canSubmit ? UIColor.B3 : UIColor.lightGray
            }
            .store(in: &cancellables)

        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.center = view.center
    }

    @IBAction func cameraButtonTapped(_: UIButton) {
        viewModel.isLoading = true

        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.navigationController?.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.viewModel.isLoading = false
        })
    }

    func imagePickerController(_: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        if let image = info[.originalImage] as? UIImage {
            viewModel.photoData = image.jpegData(compressionQuality: 0.8)
            DispatchQueue.main.async {
                self.viewModel.isPhotoSelected = true
                self.tableView.reloadData()
            }
        }

        dismiss(animated: true, completion: {
            self.viewModel.isLoading = false
        })
    }

    @objc func submitButtonTapped() {
        viewModel.saveDiary()
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - DataSource

extension NewDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.isPhotoSelected ? 2 : 1
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.isPhotoSelected && indexPath.row == 1 {
            guard let photoCell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as? PhotoTableViewCell else { return UITableViewCell() }

            if let photoData = viewModel.photoData {
                photoCell.diaryImage.image = UIImage(data: photoData)
            }

            photoCell.deletePhoto = { [weak self] in
                self?.viewModel.isPhotoSelected = false
                self?.viewModel.photoData = nil
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

            return photoCell
        } else {
            guard let contentCell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as? ContentTableViewCell else { return UITableViewCell() }

            contentCell.titleTextView.delegate = self
            contentCell.contentTextView.delegate = self

            contentCell.titleTextView.tag = 1
            contentCell.contentTextView.tag = 2

            return contentCell
        }
    }
}

// MARK: - TextView Delegate

extension NewDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 1:
            viewModel.title = textView.text ?? ""
        case 2:
            viewModel.content = textView.text ?? ""
        default:
            break
        }

        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
