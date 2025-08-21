import FirebaseAuth
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var createdEvents: [CreateEventModel] = []
    @Published var joinedEvents: [CreateEventModel] = []
    @Published var showEditProfile = false
    @Published var showCreatedAll = false
    @Published var showJoinedAll = false
    
    private let sessionManager: SessionManager
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    var displayName: String {
        let first = sessionManager.userProfile?.firstName ?? ""
        let last = sessionManager.userProfile?.lastName ?? ""
        let name = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        return name.isEmpty ? "Kullanıcı" : name
    }
    
    var initials: String {
        let first = sessionManager.userProfile?.firstName?.first.map { String($0) } ?? ""
        let last = sessionManager.userProfile?.lastName?.first.map { String($0) } ?? ""
        let combined = (first + last)
        return combined.isEmpty ? "👤" : combined.uppercased()
    }
    
    var userEmail: String {
        return sessionManager.user?.email ?? ""
    }
    
    func loadData() async {
        guard let uid = sessionManager.user?.uid else { return }
        isLoading = true
        
        async let createdTask = EventService.shared.fetchEventsCreatedBy(userId: uid)
        async let joinedTask = EventService.shared.fetchJoinedEvents(for: uid)
        
        do {
            let (createdEventsResult, joinedEventsResult) = try await (createdTask, joinedTask)
            createdEvents = createdEventsResult
            joinedEvents = joinedEventsResult
        } catch {
            Logger.error("Profile load error: \(error.localizedDescription)", category: .profile)
        }
        
        isLoading = false
    }
    
    func showEditProfileSheet() {
        showEditProfile = true
    }
    
    func showCreatedEventsSheet() {
        showCreatedAll = true
    }
    
    func showJoinedEventsSheet() {
        showJoinedAll = true
    }
    
    func signOut() {
        sessionManager.signOut()
    }
}
