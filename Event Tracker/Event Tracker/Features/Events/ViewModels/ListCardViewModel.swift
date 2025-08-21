//
//  ListCardViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.08.2025.
//

import SwiftUI
import Combine

class ListCardViewModel: ObservableObject {
    let event: CreateEventModel
    
    init(event: CreateEventModel) {
        self.event = event
    }
    
    var imageUrl: String? {
        event.images.first?.url
    }
    
    var title: String {
        event.title
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
    
    var locationName: String {
        event.location.name
    }
    
    var organizerName: String {
        event.organizer.name
    }
    
    var categories: [String] {
        event.categories
    }
    
    var priceText: String {
        if event.pricing.price > 0 {
            return "\(Int(event.pricing.price)) \(event.pricing.currency)"
        } else {
            return "Ücretsiz"
        }
    }
    
    var priceColor: Color {
        if event.pricing.price > 0 {
            return .primary
        } else {
            return .green
        }
    }
    
    var isFree: Bool {
        event.pricing.price == 0
    }
}