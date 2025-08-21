//
//  ParticipantsFilterViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.08.2025.
//

import SwiftUI
import Combine

class ParticipantsFilterViewModel: ObservableObject {
    @Published var minParticipants: Int?
    @Published var maxParticipants: Int?
    @Published var tempMinParticipants: Int?
    @Published var tempMaxParticipants: Int?
    @Published var selectedPreset: ParticipantsPreset?
    @Published var minParticipantsText: String = ""
    @Published var maxParticipantsText: String = ""
    
    private let initialMinParticipants: Int?
    private let initialMaxParticipants: Int?
    
    init(minParticipants: Int?, maxParticipants: Int?) {
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.initialMinParticipants = minParticipants
        self.initialMaxParticipants = maxParticipants
        self.tempMinParticipants = minParticipants
        self.tempMaxParticipants = maxParticipants
        self.minParticipantsText = minParticipants?.description ?? ""
        self.maxParticipantsText = maxParticipants?.description ?? ""
    }
    
    var hasChanges: Bool {
        tempMinParticipants != initialMinParticipants || tempMaxParticipants != initialMaxParticipants
    }
    
    var isValidRange: Bool {
        guard let min = tempMinParticipants, let max = tempMaxParticipants else { return true }
        return min <= max
    }
    
    func applyPreset(_ preset: ParticipantsPreset) {
        selectedPreset = preset
        let range = preset.participantsRange
        tempMinParticipants = range.min
        tempMaxParticipants = range.max
        minParticipantsText = range.min?.description ?? ""
        maxParticipantsText = range.max?.description ?? ""
    }
    
    func clearFilter() {
        tempMinParticipants = nil
        tempMaxParticipants = nil
        minParticipantsText = ""
        maxParticipantsText = ""
        selectedPreset = nil
    }
    
    func updateMinParticipants(from text: String) {
        if text.isEmpty {
            tempMinParticipants = nil
        } else if let intValue = Int(text), intValue >= 0 {
            tempMinParticipants = intValue
        }
    }
    
    func updateMaxParticipants(from text: String) {
        if text.isEmpty {
            tempMaxParticipants = nil
        } else if let intValue = Int(text), intValue >= 0 {
            tempMaxParticipants = intValue
        }
    }
    
    func clearPresetSelection() {
        selectedPreset = nil
    }
    
    func applyChanges() {
        minParticipants = tempMinParticipants
        maxParticipants = tempMaxParticipants
    }
}

enum ParticipantsPreset: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case huge = "huge"
    case popular = "popular"
    case exclusive = "exclusive"
    
    var displayName: String {
        switch self {
        case .small: return "Küçük Grup"
        case .medium: return "Orta Grup"
        case .large: return "Büyük Grup"
        case .huge: return "Çok Büyük"
        case .popular: return "Popüler"
        case .exclusive: return "Seçkin"
        }
    }
    
    var description: String {
        switch self {
        case .small: return "1-20 kişi"
        case .medium: return "21-50 kişi"
        case .large: return "51-100 kişi"
        case .huge: return "100+ kişi"
        case .popular: return "50+ katılımcı"
        case .exclusive: return "Maksimum 10 kişi"
        }
    }
    
    var icon: String {
        switch self {
        case .small: return "person.2"
        case .medium: return "person.3"
        case .large: return "person.3.sequence"
        case .huge: return "person.3.sequence.fill"
        case .popular: return "heart.fill"
        case .exclusive: return "star.fill"
        }
    }
    
    var participantsRange: (min: Int?, max: Int?) {
        switch self {
        case .small: return (1, 20)
        case .medium: return (21, 50)
        case .large: return (51, 100)
        case .huge: return (100, nil)
        case .popular: return (50, nil)
        case .exclusive: return (nil, 10)
        }
    }
}