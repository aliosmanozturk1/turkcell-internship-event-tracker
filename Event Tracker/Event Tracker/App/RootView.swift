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
                                EventView()
                                    .tabItem {
                                        Image(systemName: "figure.socialdance")
                                        Text("Events")
                                    }

                                CreateEventView()
                                    .tabItem {
                                        Image(systemName: "calendar.badge.plus")
                                        Text("Create Event")
                                    }

                                ProfileView(userEmail: sessionManager.user?.email ?? "")
                                    .tabItem {
                                        Image(systemName: "person.crop.circle")
                                        Text("Profile")
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
                    case .eventDetail(let event):
                        EventDetailView(event: event)
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
