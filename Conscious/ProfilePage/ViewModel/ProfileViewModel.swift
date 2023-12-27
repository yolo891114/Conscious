//
//  ProfileViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/22.
//

import Combine
import FirebaseAuth
import Foundation

class ProfileViewModel: ObservableObject {
    @Published var currentUserName: String?

    var cancellables = Set<AnyCancellable>()

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.currentUserName = user.displayName
            } else {
                self?.currentUserName = nil
            }
        }
    }
}
