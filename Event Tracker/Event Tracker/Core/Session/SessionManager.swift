import FirebaseAuth
import SwiftUI
import Combine

@MainActor
final class SessionManager: ObservableObject {
    // Published Firebase user instance
    @Published private(set) var user: User?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Current user on launch
        self.user = Auth.auth().currentUser
        
        // Listen to Firebase auth state changes
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.user = user
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    var isSignedIn: Bool { user != nil }
    
    // Sign-out helper so views can call directly
    func signOut() {
        do {
            try AuthService.shared.signOut()
            // Update immediately; listener will confirm
            self.user = nil
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
} 
