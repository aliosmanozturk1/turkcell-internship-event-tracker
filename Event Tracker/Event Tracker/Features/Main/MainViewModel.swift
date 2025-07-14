import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published var isSigningOut = false

    func signOut() {
        isSigningOut = true
        do {
            try AuthService.shared.signOut()
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
        isSigningOut = false
    }
} 

