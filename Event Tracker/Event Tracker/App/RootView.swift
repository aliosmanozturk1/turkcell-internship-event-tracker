import FirebaseAuth
import SwiftUI

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
                        if let _ = sessionManager.userProfile {
                            TabView {
                                Tab("Events", systemImage: "figure.socialdance") {
                                    
                                }

                                Tab("Map", systemImage: "map.fill") {
                                    
                                }

                                Tab("Profile", systemImage: "person.crop.circle") {
                                    ProfileView(userEmail: sessionManager.user?.email ?? "")
                                }
                            }
                        } else {
                            CompleteProfileView()
                        }
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
