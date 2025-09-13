//
//  LoginViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 10.07.2025.
//

import Combine
import Foundation
import FirebaseAuth
import AuthenticationServices

@MainActor
final class LoginViewModel: ObservableObject {
    // Input
    @Published var email: String = ""
    @Published var password: String = ""
    
    // UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLogin: Bool = false
    
    private var currentNonce: String?
    
    func login() async {
        // Input validation
        guard !email.isEmpty else {
            errorMessage = StringConstants.ErrorMessages.emailCannotBeEmpty
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = StringConstants.ErrorMessages.passwordCannotBeEmpty
            return
        }
            
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
            
        do {
            _ = try await AuthService.shared.signIn(email: email, password: password)
            isLogin = true
        } catch {
            isLogin = false
            errorMessage = error.localizedDescription
        }
    }
    
    func loginWithGoogle() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let user = try await AuthService.shared.signInWithGoogle()
            // Google'dan gelen kullanıcı email'ini kullan
            email = user.email ?? ""
            isLogin = true
        } catch {
            isLogin = false
            errorMessage = error.localizedDescription
        }
    }
    
    func loginWithApple(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        // Store nonce for later use
        currentNonce = nonce
    }
    
    func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let idToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: idToken, encoding: .utf8),
                  let nonce = currentNonce else {
                isLogin = false
                errorMessage = StringConstants.ErrorMessages.appleSignInFailed
                return
            }
            
            do {
                let user = try await AuthService.shared.signInWithApple(idToken: idTokenString, nonce: nonce)
                email = user.email ?? ""
                isLogin = true
                currentNonce = nil
            } catch {
                isLogin = false
                errorMessage = error.localizedDescription
            }
            
        case .failure(let error):
            isLogin = false
            errorMessage = error.localizedDescription
        }
    }
        
    func clear() {
        email = ""
        password = ""
        errorMessage = nil
        isLogin = false
    }
}
