//
//  SettingPasswordViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Combine
import Foundation
import SwiftUI
import UIKit

class SettingPasswordViewController: UIViewController {
    var viewModel: SettingPasswordViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SettingPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.settingSuccess
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)

        let settingPasswordView = SettingPasswordView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: settingPasswordView)

        addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        hostingController.didMove(toParent: self)
    }
}

struct SettingPasswordView: View {
    @ObservedObject var viewModel: SettingPasswordViewModel
    @State private var showError: Bool = false

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

            // 自定義數字鍵盤
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

                // 為0和刪除按鈕添加一個特殊的行
                HStack(spacing: 10) {
                    Button(action: {
                        viewModel.settingSuccess.send()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .frame(width: 60, height: 60)
                    }

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
    }
}
