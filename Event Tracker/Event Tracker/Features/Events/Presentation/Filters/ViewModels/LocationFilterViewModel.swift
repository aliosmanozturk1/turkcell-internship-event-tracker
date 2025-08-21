//
//  LocationFilterViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.08.2025.
//

import SwiftUI
import Combine

class LocationFilterViewModel: ObservableObject {
    @Published var location: String?
    @Published var tempLocation: String
    @Published var selectedPreset: LocationPreset?
    
    private let initialLocation: String?
    
    init(location: String?) {
        self.location = location
        self.initialLocation = location
        self.tempLocation = location ?? ""
    }
    
    var hasChanges: Bool {
        let newValue = tempLocation.isEmpty ? nil : tempLocation
        return newValue != initialLocation
    }
    
    func applyPreset(_ preset: LocationPreset) {
        selectedPreset = preset
        tempLocation = preset.locationName
    }
    
    func clearFilter() {
        tempLocation = ""
        selectedPreset = nil
    }
    
    func clearPresetSelection() {
        selectedPreset = nil
    }
    
    func applyChanges() {
        location = tempLocation.isEmpty ? nil : tempLocation
    }
}

enum LocationPreset: String, CaseIterable {
    case istanbul = "istanbul"
    case ankara = "ankara"
    case izmir = "izmir"
    case bursa = "bursa"
    case antalya = "antalya"
    case adana = "adana"
    
    var displayName: String {
        switch self {
        case .istanbul: return "İstanbul"
        case .ankara: return "Ankara"
        case .izmir: return "İzmir"
        case .bursa: return "Bursa"
        case .antalya: return "Antalya"
        case .adana: return "Adana"
        }
    }
    
    var description: String {
        switch self {
        case .istanbul: return "Türkiye'nin en büyük şehri"
        case .ankara: return "Türkiye'nin başkenti"
        case .izmir: return "Ege'nin incisi"
        case .bursa: return "Yeşil Bursa"
        case .antalya: return "Turizm başkenti"
        case .adana: return "Çukurova'nın merkezi"
        }
    }
    
    var icon: String {
        switch self {
        case .istanbul: return "building.2.fill"
        case .ankara: return "star.circle.fill"
        case .izmir: return "water.waves"
        case .bursa: return "leaf.fill"
        case .antalya: return "sun.max.fill"
        case .adana: return "location.circle.fill"
        }
    }
    
    var locationName: String {
        return displayName
    }
}