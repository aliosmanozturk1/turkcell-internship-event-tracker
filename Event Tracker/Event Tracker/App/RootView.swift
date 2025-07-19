import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var router: Router
    @State private var showSplash = true
    
    var body: some View {
        if showSplash {
            SplashScreenView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
        } else {
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
}

#Preview {
    RootView()
        .environmentObject(SessionManager())
        .environmentObject(Router())
} 
