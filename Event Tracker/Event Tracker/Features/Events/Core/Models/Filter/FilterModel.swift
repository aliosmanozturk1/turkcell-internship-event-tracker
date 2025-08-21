//
//  FilterModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import Foundation

enum FilterType: String, CaseIterable {
    case category = "category"
    case date = "date"
    case price = "price"
    case location = "location"
    case participants = "participants"
    
    var displayName: String {
        switch self {
        case .category: return "Kategori"
        case .date: return "Tarih Aralığı"
        case .price: return "Fiyat Aralığı"
        case .location: return "Konum"
        case .participants: return "Katılımcı Sayısı"
        }
    }
    
    var icon: String {
        switch self {
        case .category: return "tag.fill"
        case .date: return "calendar"
        case .price: return "dollarsign.circle.fill"
        case .location: return "location.fill"
        case .participants: return "person.3.fill"
        }
    }
    
    var description: String {
        switch self {
        case .category: return "Etkinlik kategorilerine göre filtrele"
        case .date: return "Belirli tarih aralığında filtrele"
        case .price: return "Fiyat aralığına göre filtrele"
        case .location: return "Konum bilgisine göre filtrele"
        case .participants: return "Katılımcı sayısına göre filtrele"
        }
    }
}

struct EventFilter {
    var selectedCategories: Set<String> = []
    var startDate: Date?
    var endDate: Date?
    var minPrice: Double?
    var maxPrice: Double?
    var location: String?
    var minParticipants: Int?
    var maxParticipants: Int?
    
    var isActive: Bool {
        return !selectedCategories.isEmpty ||
               startDate != nil ||
               endDate != nil ||
               minPrice != nil ||
               maxPrice != nil ||
               location != nil ||
               minParticipants != nil ||
               maxParticipants != nil
    }
    
    var activeFilterCount: Int {
        var count = 0
        if !selectedCategories.isEmpty { count += 1 }
        if startDate != nil || endDate != nil { count += 1 }
        if minPrice != nil || maxPrice != nil { count += 1 }
        if location != nil { count += 1 }
        if minParticipants != nil || maxParticipants != nil { count += 1 }
        return count
    }
    
    mutating func clear() {
        selectedCategories.removeAll()
        startDate = nil
        endDate = nil
        minPrice = nil
        maxPrice = nil
        location = nil
        minParticipants = nil
        maxParticipants = nil
    }
    
    func matches(event: CreateEventModel) -> Bool {
        // Category filter
        if !selectedCategories.isEmpty {
            let eventCategories = Set(event.categories)
            if selectedCategories.intersection(eventCategories).isEmpty {
                return false
            }
        }
        
        // Date filter
        if let startDate = startDate, event.startDate < startDate {
            return false
        }
        
        if let endDate = endDate, event.startDate > endDate {
            return false
        }
        
        // Price filter
        if let minPrice = minPrice, event.pricing.price < minPrice {
            return false
        }
        
        if let maxPrice = maxPrice, event.pricing.price > maxPrice {
            return false
        }
        
        // Location filter
        if let location = location, !location.isEmpty {
            let searchText = location.lowercased()
            let locationMatches = event.location.name.lowercased().contains(searchText) ||
                                event.location.address1.lowercased().contains(searchText) ||
                                event.location.city.lowercased().contains(searchText) ||
                                event.location.district.lowercased().contains(searchText) ||
                                event.location.fullAddress.lowercased().contains(searchText)
            
            if !locationMatches {
                return false
            }
        }
        
        // Participants filter
        if let minParticipants = minParticipants, 
           event.participants.currentParticipants < minParticipants {
            return false
        }
        
        if let maxParticipants = maxParticipants,
           event.participants.currentParticipants > maxParticipants {
            return false
        }
        
        return true
    }
}