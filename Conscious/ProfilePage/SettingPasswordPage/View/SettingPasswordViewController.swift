//
//  SettingPasswordViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class SettingPasswordViewController: UIViewController {

    var viewModel: SettingPasswordViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SettingPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.settingSuccess
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)

        let settingPasswordView = SettingPasswordView(viewModel: self.viewModel)

        let hostingController = UIHostingController(rootView: settingPasswordView)

        self.addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

struct SettingPasswordView: View {
    @ObservedObject var viewModel: SettingPasswordViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.mode == .setting ? "Enter Password" : "Update Password")

            // 顯示輸入的密碼
            Text(viewModel.inputPassword)
                .font(.title)
                .padding()

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
