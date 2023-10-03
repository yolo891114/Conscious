//
//  EnterPasswordViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import Combine

class EnterPasswordViewModel: ObservableObject {

    @Published var inputPassword: String = ""
    @Published var isUnlock: Bool = false
    private var passwordManager = PasswordManager()
    let unlockSuccess = PassthroughSubject<Void, Never>()
    let triggerFaceID = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        $inputPassword
            .sink { password in
                if password.count == 4 {
                    DispatchQueue.main.async {
                        self.checkPasswordAndUnlock()
                    }
                }
            }
            .store(in: &cancellables)
    }

    var isValidPassword: Bool {
        print(passwordManager.getPassword())
        return inputPassword == passwordManager.getPassword()
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

    func checkPasswordAndUnlock() {
        if isValidPassword {
            unlockSuccess.send(())
        }
    }

}
