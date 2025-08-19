//
//  RegisterViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 10.07.2025.
//

import Combine
import Foundation

@MainActor
final class RegisterViewModel: ObservableObject {
    // Input
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    // UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isRegistered: Bool = false
    
    func register() async {
        // Input validation
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty."
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty."
            return
        }
        
        guard !confirmPassword.isEmpty else {
            errorMessage = "Password cannot be empty."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
            
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
            
        do {
            _ = try await AuthService.shared.signUp(email: email, password: password)
            isRegistered = true
        } catch {
            isRegistered = false
            errorMessage = error.localizedDescription
        }
    }
        
    func clear() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
        isRegistered = false
    }
}
