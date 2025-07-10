//
//  Event_TrackerApp.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 9.07.2025.
//

import FirebaseCore
import SwiftUI
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
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
