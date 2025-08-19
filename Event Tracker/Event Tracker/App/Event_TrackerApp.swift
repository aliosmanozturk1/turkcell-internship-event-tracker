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


final class AppDelegate: NSObject, UIApplicationDelegate {
    /// Tells the delegate that the launch process is almost done and the app is almost ready to run.
    ///
    /// You should use this method to perform any final initialization before your app is presented to the user.
    /// Typical tasks performed here include:
    /// - Initializing third-party services (e.g. Firebase, analytics, crash reporting)
    /// - Configuring sign-in providers (e.g. Google Sign-In)
    /// - Restoring application state
    ///
    /// - Parameters:
    ///   - application: The singleton app object. 
    ///   - launchOptions: A dictionary indicating the reason the app was launched (if any). The contents of this dictionary may be empty when the user launches the app normally.
    /// - Returns: `true` if the app launch process succeeded and the app is ready to run; otherwise, `false`.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Google Sign-in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Firebase clientID not found")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        return true
    }
    
    /// The `AppDelegate` class is responsible for handling application-level events and initializations.
    ///
    /// Responsibilities include:
    /// - Configuring Firebase and Google Sign-In during app launch.
    /// - Handling URL callbacks for Google Sign-In and other authentication flows.
    ///
    /// This class conforms to the `UIApplicationDelegate` protocol and is referenced via the
    /// `@UIApplicationDelegateAdaptor` property wrapper in the main application struct.
    ///
    /// Important behaviors:
    /// - On launch, it initializes Firebase and sets up the Google Sign-In client configuration.
    /// - Handles incoming URLs to process authentication callbacks, forwarding them to the Google Sign-In SDK.
    // Google Sign-In URL handling
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

/// The main entry point for the Event Tracker app.
///
/// `Event_TrackerApp` is the root SwiftUI application structure, responsible for:
/// - Registering and initializing the `AppDelegate`, which configures core services such as Firebase and Google Sign-In.
/// - Creating and managing shared state objects, including the `SessionManager` (for authentication and session state)
///   and the `Router` (for navigation and flow control).
/// - Injecting these shared objects into the SwiftUI environment, making them accessible throughout the app's view hierarchy.
/// - Providing the root scene via `WindowGroup`, which launches the primary user interface (`RootView`).
///
/// This struct uses property wrappers such as:
/// - `@UIApplicationDelegateAdaptor` to bridge UIKit's app delegate lifecycle with SwiftUI.
/// - `@StateObject` to manage the lifecycle of observable objects used for app-wide state management.
///
/// The application's architecture enables modularity, facilitates authentication flows, and supports programmatic navigation.
@main
struct Event_TrackerApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Session manager shared for the app lifecycle
    @StateObject private var sessionManager = SessionManager()
    // Router for navigation
    @StateObject private var router = Router()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
                .environmentObject(router)
        }
    }
}
