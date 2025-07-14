import SwiftUI
import Combine

// MARK: - AppRoute

enum AppRoute: Hashable {
    case register
    // Future routes can be added here (e.g., eventDetail(id: String))
}

// MARK: - Router (Navigation Coordinator)

@MainActor
final class Router: ObservableObject {
    @Published var path = NavigationPath()
    
    // Push new route to navigation stack
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    // Pop the last route
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    // Pop to root
    func popToRoot() {
        path.removeLast(path.count)
    }
} 
