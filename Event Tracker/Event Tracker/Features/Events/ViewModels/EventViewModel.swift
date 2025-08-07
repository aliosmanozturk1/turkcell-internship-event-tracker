//
//  EventViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI
import Combine

enum SortOption: String, CaseIterable {
    case dateAscending = "dateAsc"
    case dateDescending = "dateDesc"
    case titleAscending = "titleAsc"
    case titleDescending = "titleDesc"
    case priceAscending = "priceAsc"
    case priceDescending = "priceDesc"
    case participantsAscending = "participantsAsc"
    case participantsDescending = "participantsDesc"
    
    var displayName: String {
        switch self {
        case .dateAscending: return "Tarihe Göre (Eskiden Yeniye)"
        case .dateDescending: return "Tarihe Göre (Yeniden Eskiye)"
        case .titleAscending: return "İsme Göre (A-Z)"
        case .titleDescending: return "İsme Göre (Z-A)"
        case .priceAscending: return "Fiyata Göre (Düşükten Yükseğe)"
        case .priceDescending: return "Fiyata Göre (Yüksekten Düşüğe)"
        case .participantsAscending: return "Katılımcı Sayısına Göre (Az-Çok)"
        case .participantsDescending: return "Katılımcı Sayısına Göre (Çok-Az)"
        }
    }
}

enum ViewOption: String, CaseIterable {
    case list = "list"
    case grid = "grid"
    case compact = "compact"
    
    var displayName: String {
        switch self {
        case .list: return "Liste"
        case .grid: return "Izgara"
        case .compact: return "Kompakt"
        }
    }
    
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        case .compact: return "rectangle.grid.1x2"
        }
    }
}

@MainActor
final class EventViewModel: ObservableObject {
    @Published var events: [CreateEventModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedSortOption: SortOption = .dateDescending {
        didSet { applySorting() }
    }
    @Published var selectedViewOption: ViewOption = .list

    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            events = try await EventService.shared.fetchEvents()
            applySorting()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func applySorting() {
        switch selectedSortOption {
        case .dateAscending:
            events = events.sorted { $0.startDate < $1.startDate }
        case .dateDescending:
            events = events.sorted { $0.startDate > $1.startDate }
        case .titleAscending:
            events = events.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            events = events.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .priceAscending:
            events = events.sorted { $0.pricing.price < $1.pricing.price }
        case .priceDescending:
            events = events.sorted { $0.pricing.price > $1.pricing.price }
        case .participantsAscending:
            events = events.sorted { $0.participants.currentParticipants < $1.participants.currentParticipants }
        case .participantsDescending:
            events = events.sorted { $0.participants.currentParticipants > $1.participants.currentParticipants }
        }
    }
}
