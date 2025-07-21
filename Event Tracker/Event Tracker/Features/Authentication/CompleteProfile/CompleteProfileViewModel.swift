//
//  CompleteProfileViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.07.2025.
//

import Combine
import Foundation
import FirebaseAuth
import Firebase

@MainActor
class CompleteProfileViewModel: ObservableObject {
    // Input
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    // UI State
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var isProfileCompleted: Bool = false

    func saveProfile() async {
        guard !firstName.isEmpty else {
            errorMessage = "First name cannot be empty."
            return
        }

        guard !lastName.isEmpty else {
            errorMessage = "Last name cannot be empty."
            return
        }

        guard let user = AuthService.shared.currentUser, let email = user.email else {
            errorMessage = "User not found"
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            try await UserService.shared.createUser(uid: user.uid,
                                                    email: email,
                                                    firstName: firstName,
                                                    lastName: lastName)
            isProfileCompleted = true
        } catch {
            errorMessage = error.localizedDescription
            isProfileCompleted = false
        }

        isSaving = false
    }
}
