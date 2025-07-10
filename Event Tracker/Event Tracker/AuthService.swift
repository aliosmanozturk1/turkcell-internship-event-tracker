//
//  AuthService.swift
//  Event Tracker
//
//  Created by Assistant on 10.07.2025.
//

import FirebaseAuth
import Foundation

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
        
    func signOut() throws {
        try auth.signOut()
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
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Kullanıcı bulunamadı"
            case .invalidCredentials:
                return "Geçersiz kullanıcı bilgileri"
            case .networkError:
                return "İnternet bağlantısını kontrol edin"
            case .unknown:
                return "Bilinmeyen bir hata oluştu"
            }
        }
    }
}
