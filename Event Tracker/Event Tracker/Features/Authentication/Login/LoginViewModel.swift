//
//  LoginViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 10.07.2025.
//

import Combine
import Foundation
import FirebaseAuth

@MainActor
class LoginViewModel: ObservableObject {
    // Input
    @Published var email: String = ""
    @Published var password: String = ""
    
    // UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLogin: Bool = false
    
    func login() async {
        // Input validation
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty."
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty."
            return
        }
            
        isLoading = true
        errorMessage = nil
            
        do {
            _ = try await AuthService.shared.signIn(email: email, password: password)
            isLogin = true
        } catch {
            isLogin = false
            if let error = error as? AuthService.AuthError {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
            
        isLoading = false
    }
    
    func loginWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await AuthService.shared.signInWithGoogle()
            // Google'dan gelen kullanıcı email'ini kullan
            email = user.email ?? ""
            isLogin = true
        } catch {
            isLogin = false
            if let error = error as? AuthService.AuthError {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    func loginWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await AuthService.shared.signInWithApple()
            // Apple'dan gelen kullanıcı email'ini kullan
            email = user.email ?? ""
            isLogin = true
        } catch {
            isLogin = false
            if let error = error as? AuthService.AuthError {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
        
    func clear() {
        email = ""
        password = ""
        errorMessage = nil
        isLogin = false
    }
}
