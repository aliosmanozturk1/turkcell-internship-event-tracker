//
//  Event_TrackerApp.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 9.07.2025.
//

import FirebaseCore
import SwiftUI
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Google Sign-in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Firebase clientID bulunamadı")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        return true
    }
    
    // Google Sign-In URL handling
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct Event_TrackerApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            if AuthService.shared.isUserSignedIn {
                MainView(userEmail: AuthService.shared.currentUser?.email ?? "")
            } else {
                LoginView()
            }
        }
    }
}
