//
//  EnterPasswordViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import LocalAuthentication

class EnterPasswordViewController: UIViewController {

    lazy var viewModel = EnterPasswordViewModel()
    private var cancellables = Set<AnyCancellable>()

    //    let faceIDButton: UIButton = {
    //        let button = UIButton()
    //        button.setImage(UIImage(named: "faceid"), for: .normal)
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        return button
    //    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.unlockSuccess
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)

        viewModel.triggerFaceID
                .sink { [weak self] in
                    self?.faceIDButtonTapped()
                }
                .store(in: &cancellables)

        let passwordView = PasswordView(viewModel: self.viewModel)

        let hostingController = UIHostingController(rootView: passwordView)

        self.addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])

        hostingController.didMove(toParent: self)

        //        biometricsLogin()
    }

    func faceIDButtonTapped() {
        // 創建 LAContext 實例
        let context = LAContext()
        // 設置取消按鈕標題
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        // 評估是否可以針對給定方案進行身份驗證
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in to your account"
            // 評估指定方案
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
                    DispatchQueue.main.async { [unowned self] in
                        GlobalState.isUnlock = true
                        viewModel.unlockSuccess.send()
                    }
                }
            }
        }
    }

    func showMessage(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

struct PasswordView: View {
    @ObservedObject var viewModel = EnterPasswordViewModel()

    init(viewModel: EnterPasswordViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Password")

            // 顯示輸入的密碼
            Text(viewModel.inputPassword)
                .font(.title)
                .padding()

            Button(action: {
                viewModel.triggerFaceID.send()
            }) {
                Image(systemName: "faceid") // 使用 SF Symbols，或者您可以使用自己的圖片
                    .resizable()
                    .frame(width: 30, height: 30)
            }

            // 自定義數字鍵盤
            VStack(spacing: 10) {
                ForEach(0..<3) { row in
                    HStack(spacing: 10) {
                        ForEach(1..<4) { col in
                            let number = row * 3 + col
                            Button("\(number)") {
                                viewModel.appendInputPassword(number: String(number))
                            }
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(30)
                        }
                    }
                }

                // 為0和刪除按鈕添加一個特殊的行
                HStack(spacing: 10) {
                    Button("Delete") {
                        viewModel.deleteInputPassword()
                    }
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(30)

                    Button("0") {
                        viewModel.appendInputPassword(number: "0")
                    }
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(30)
                }
            }
        }
    }
}
