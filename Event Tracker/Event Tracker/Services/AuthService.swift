//
//  AuthService.swift
//  Event Tracker
//
//  Created by Assistant on 10.07.2025.
//

import FirebaseAuth
import Foundation
import GoogleSignIn
import FirebaseCore

final class AuthService {
    static let shared = AuthService()
    private let auth = FirebaseManager.shared.auth
    
    private init() {}

    // MARK: - Current User
        
    var currentUser: User? {
        auth.currentUser
    }
        
    var isUserSignedIn: Bool {
        currentUser != nil
    }
        
    // MARK: - Authentication Methods
        
    func signUp(email: String, password: String) async throws -> User {
        let authDataResult = try await auth.createUser(withEmail: email, password: password)
        return authDataResult.user
    }
        
    func signIn(email: String, password: String) async throws -> User {
        let authDataResult = try await auth.signIn(withEmail: email, password: password)
        return authDataResult.user
    }
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle() async throws -> User {
        // Google Sign-In konfigürasyonunu kontrol et
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.configurationError
        }
        
        // Google Sign-In konfigürasyonunu ayarla
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        // SwiftUI için root view controller'ı al
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        // Google Sign-In işlemini başlat
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        // Google kimlik bilgilerini al
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.tokenError
        }
        
        let accessToken = result.user.accessToken.tokenString
        
        // Firebase credential oluştur
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // Firebase'e giriş yap
        let authResult = try await auth.signIn(with: credential)
        return authResult.user
    }
        
    func signOut() throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()
    }
        
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
        
    func deleteAccount() async throws {
        guard let user = currentUser else {
            throw AuthError.userNotFound
        }
        try await user.delete()
    }
    
    enum AuthError: LocalizedError {
        case userNotFound
        case invalidCredentials
        case networkError
        case configurationError
        case noRootViewController
        case tokenError
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "User not found"
            case .invalidCredentials:
                return "Invalid user credentials"
            case .networkError:
                return "Please check your internet connection"
            case .configurationError:
                return "Google Sign-In configuration error"
            case .noRootViewController:
                return "Application view not found"
            case .tokenError:
                return "Google authentication error"
            case .unknown:
                return "An unknown error occurred"
            }
        }
        }
    }
}
