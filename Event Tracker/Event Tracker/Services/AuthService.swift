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
import AuthenticationServices
import CryptoKit

final class AuthService {
    static let shared = AuthService()
    private let auth = FirebaseManager.shared.auth
    
    // Apple Sign In nonce
    private var currentNonce: String?
    
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
    
    // MARK: - Apple Sign-In
    
    func signInWithApple() async throws -> User {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = AppleSignInDelegate(continuation: continuation, currentNonce: nonce)
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            authorizationController.performRequests()
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
        
    func signOut() throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()
        currentNonce = nil
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
        case appleSignInFailed
        case appleSignInCancelled
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
            case .appleSignInFailed:
                return "Apple Sign In failed"
            case .appleSignInCancelled:
                return "Apple Sign In was cancelled"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
}

// MARK: - Apple Sign In Delegate

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<User, Error>
    private let currentNonce: String
    
    init(continuation: CheckedContinuation<User, Error>, currentNonce: String) {
        self.continuation = continuation
        self.currentNonce = currentNonce
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce.isEmpty ? nil : currentNonce else {
                continuation.resume(throwing: AuthService.AuthError.appleSignInFailed)
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                continuation.resume(throwing: AuthService.AuthError.appleSignInFailed)
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                continuation.resume(throwing: AuthService.AuthError.appleSignInFailed)
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            Task {
                do {
                    let authResult = try await FirebaseManager.shared.auth.signIn(with: credential)
                    continuation.resume(returning: authResult.user)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        } else {
            continuation.resume(throwing: AuthService.AuthError.appleSignInFailed)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                continuation.resume(throwing: AuthService.AuthError.appleSignInCancelled)
            default:
                continuation.resume(throwing: AuthService.AuthError.appleSignInFailed)
            }
        } else {
            continuation.resume(throwing: error)
        }
    }
}
