//
//  ProfileViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/22.
//

import Foundation
import Combine
import FirebaseAuth

class ProfileViewModel: ObservableObject {

    @Published var currentUserName: String?
    var cancellables = Set<AnyCancellable>()

    init() {

        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                self?.currentUserName = user.displayName
            } else {
                self?.currentUserName = nil
            }
        }

    }
}
