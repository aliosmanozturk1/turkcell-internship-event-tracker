import Combine
import FirebaseAuth
import SwiftUI

@MainActor
final class SessionManager: ObservableObject {
    // Published Firebase user instance
    @Published private(set) var user: User?
    @Published private(set) var userProfile: UserModel?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Current user on launch
        self.user = Auth.auth().currentUser
        if let user = self.user {
            Task { await self.loadUserProfile(for: user) }
        }
        
        // Listen to Firebase auth state changes
        self.authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.user = user
            if let user {
                Task {
                    await self.loadUserProfile(for: user)
                }
            } else {
                self.userProfile = nil
            }
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    var isSignedIn: Bool { self.user != nil }
    
    // Sign-out helper so views can call directly
    func signOut() {
        do {
            try AuthService.shared.signOut()
            // Update immediately; listener will confirm
            self.user = nil
            self.userProfile = nil
        } catch {
            Logger.error("Sign out error: \(error.localizedDescription)", category: .session)
        }
    }

    private func loadUserProfile(for user: User) async {
        do {
            self.userProfile = try await UserService.shared.fetchUser(uid: user.uid)
        } catch {
            Logger.error("Failed to fetch user profile: \(error.localizedDescription)", category: .session)
            self.userProfile = nil
        }
    }

    func refreshUserProfile() async {
        guard let user else {
            self.userProfile = nil
            return
        }
        await self.loadUserProfile(for: user)
    }
}
