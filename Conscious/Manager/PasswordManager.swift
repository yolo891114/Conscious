//
//  PasswordManager.swift
//  Conscious
//
//  Created by jeff on 2023/9/21.
//

import Foundation
import Security

class PasswordManager {
    static let shared = PasswordManager()

    func savePassword(password: String) {
        let passwordData = password.data(using: .utf8)!

        let query: [String: Any] = [
            kSecValueData as String: passwordData,
            kSecAttrService as String: "ConsciousDiary",
            kSecClass as String: kSecClassGenericPassword,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        print("status: \(status)")
    }

    func getPassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "ConsciousDiary",
            kSecReturnData as String: kCFBooleanTrue!,
        ]

        var returnData: AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &returnData)

        // 判斷操作成功與否
        if status == errSecSuccess {
            if let data = returnData as? Data,
               let password = String(data: data, encoding: .utf8)
            {
                return password
            }
        }
        return nil
    }

    func updatePassword(newPassword: String) {
        // 刪除舊密碼
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "ConsciousDiary",
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // 儲存新密碼
        savePassword(password: newPassword)
    }
}

enum GlobalState {
    static var isLock: Bool = false
}
