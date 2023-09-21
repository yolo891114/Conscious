//
//  EnterPasswordViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation

class EnterPasswordViewModel: ObservableObject {

    @Published var inputPassword: String = ""

    let correctPassword = "1234"

    var isValidPassword: Bool {
        return inputPassword == correctPassword
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

}
