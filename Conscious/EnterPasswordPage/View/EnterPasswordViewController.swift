//
//  EnterPasswordViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Combine
import Foundation
import LocalAuthentication
import SwiftUI
import UIKit

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

        let passwordView = PasswordView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: passwordView)

        addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        hostingController.didMove(toParent: self)
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
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                if success {
                    DispatchQueue.main.async { [unowned self] in
                        GlobalState.isLock = false
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
        present(alertController, animated: true, completion: nil)
    }
}

struct PasswordView: View {
    @ObservedObject var viewModel = EnterPasswordViewModel()
    @State private var showError: Bool = false

    init(viewModel: EnterPasswordViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Password")

            HStack(spacing: 15) {
                ForEach(0 ..< 4) { index in
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .fill(viewModel.inputPassword.count > index ? Color.black : Color.clear)
                                .frame(width: 12, height: 12)
                        )
                }
            }
            .padding()
            .modifier(Shake(animatableData: showError ? CGFloat(1) : CGFloat(0)))

            Button(action: {
                viewModel.triggerFaceID.send()
            }) {
                Image(systemName: "faceid")
                    .resizable()
                    .frame(width: 30, height: 30)
            }

            VStack(spacing: 10) {
                ForEach(0 ..< 3) { row in
                    HStack(spacing: 10) {
                        ForEach(1 ..< 4) { col in
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

                HStack(spacing: 10) {
                    Color.clear
                        .frame(width: 60, height: 60)
                        .background(Color.clear)

                    Button("0") {
                        viewModel.appendInputPassword(number: "0")
                    }
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(30)

                    Button(action: {
                        viewModel.deleteInputPassword()
                    }) {
                        Image(systemName: "delete.left")
                            .font(.title)
                            .frame(width: 60, height: 60)
                    }
                }
            }
        }
        .onChange(of: viewModel.inputPassword) { newValue in
            if newValue.count == 4 {
                // 檢查密碼是否正確
                if !viewModel.isValidPassword {
                    withAnimation {
                        showError.toggle()
                    }
                    print(showError)
                }
            }
        }
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size _: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}
