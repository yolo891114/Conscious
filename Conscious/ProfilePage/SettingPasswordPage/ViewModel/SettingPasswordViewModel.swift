//
//  SettingPasswordViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import Combine

// TODO: 更改密碼前輸入舊密碼 / 換密碼時確認密碼

enum PasswordMode {
    case setting
    case updating
}

class SettingPasswordViewModel: ObservableObject {

    @Published var inputPassword: String = ""
    private var passwordManager = PasswordManager()
    private var cancellables = Set<AnyCancellable>()
    let settingSuccess = PassthroughSubject<Void, Never>()
    var mode: PasswordMode = .setting

    init(mode: PasswordMode) {
        self.mode = mode
        $inputPassword
            .sink { password in
                if password.count == 4 {
                    DispatchQueue.main.async {
                        self.saveOrUpdatePassword()
                    }
                }
            }
            .store(in: &cancellables)
    }

    var isValidPassword: Bool {
        return inputPassword.count == 4
    }

    func appendInputPassword(number: String) {
        if inputPassword.count < 4 {
            inputPassword += number
        }
    }

    func deleteInputPassword() {
        if !inputPassword.isEmpty {
            inputPassword.removeLast()
        }
    }

    func saveOrUpdatePassword() {
        switch mode {
        case .setting:
            passwordManager.savePassword(password: inputPassword)
            settingSuccess.send()
        case .updating:
            passwordManager.updatePassword(newPassword: inputPassword)
            settingSuccess.send()
        }
    }

}
