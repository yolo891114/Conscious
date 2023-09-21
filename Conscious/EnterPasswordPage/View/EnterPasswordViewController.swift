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

class EnterPasswordViewController: UIViewController {

    lazy var viewModel = EnterPasswordViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let passwordView = PasswordView(viewModel: viewModel)

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
    }
}


struct PasswordView: View {
    @ObservedObject var viewModel = EnterPasswordViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Password")

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

            // 解鎖按鈕
            Button("Unlock") {
                if viewModel.isValidPassword {
                    // 解鎖操作
                    print("Unlock")
                }
            }
            .disabled(!viewModel.isValidPassword)
        }
    }
}
