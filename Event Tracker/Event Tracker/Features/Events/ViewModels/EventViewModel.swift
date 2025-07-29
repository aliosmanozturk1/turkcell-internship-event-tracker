//
//  EventViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI
import Combine

@MainActor
final class EventViewModel: ObservableObject {
    @Published var events: [CreateEventModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            events = try await EventService.shared.fetchEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
