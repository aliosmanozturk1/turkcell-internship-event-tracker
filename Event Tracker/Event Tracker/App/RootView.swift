import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var router: Router
    
    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if sessionManager.isSignedIn {
                    MainView(userEmail: sessionManager.user?.email ?? "")
                } else {
                    LoginView()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .register:
                    RegisterView()
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(SessionManager())
        .environmentObject(Router())
} 
