//
//  CreateEventModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 29.07.2025.
//

import Foundation
import FirebaseFirestore

// MARK: - Constants
extension CreateEventModel {
    enum TimeConstants {
        static let oneDayInSeconds: TimeInterval = 86400
        static let twentyFiveHoursInSeconds: TimeInterval = 90000
        static let twentyThreeHoursInSeconds: TimeInterval = 82800
    }
}

struct CreateEventModel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String = ""
    var description: String = ""
    var categories: [String] = []
    var whatToExpected: String = ""
    var startDate: Date = Date().addingTimeInterval(TimeConstants.oneDayInSeconds)
    var endDate: Date = Date().addingTimeInterval(TimeConstants.twentyFiveHoursInSeconds)
    var registrationDeadline: Date = Date().addingTimeInterval(TimeConstants.twentyThreeHoursInSeconds)
    var location: EventLocation = EventLocation()
    var participants: EventParticipants = EventParticipants()
    var ageRestriction: AgeRestriction = AgeRestriction()
    var language: String = "tr"
    var requirements: String = ""
    var organizer: EventOrganizer = EventOrganizer()
    var pricing: EventPricing = EventPricing()
    var socialLinks: String = ""
    var contactInfo: String = ""
    var images: [EventImage] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var createdBy: String = ""
}

struct EventLocation: Codable, Hashable {
    var name: String
    var address1: String
    var address2: String
    var city: String
    var district: String
    var latitude: String
    var longitude: String
    
    init(
        name: String = "",
        address1: String = "",
        address2: String = "",
        city: String = "",
        district: String = "",
        latitude: String = "",
        longitude: String = ""
    ) {
        self.name = name
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.district = district
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var fullAddress: String {
        let components = [address1, address2, district, city].filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }
}

struct EventParticipants: Codable, Hashable {
    var maxParticipants: Int
    var currentParticipants: Int
    var showRemaining: Bool
    
    init(
        maxParticipants: Int = 0,
        currentParticipants: Int = 0,
        showRemaining: Bool = true
    ) {
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
        self.showRemaining = showRemaining
    }
    
    var remainingSpots: Int {
        max(0, maxParticipants - currentParticipants)
    }
    
    var isFull: Bool {
        maxParticipants > 0 && currentParticipants >= maxParticipants
    }
}

struct AgeRestriction: Codable, Hashable {
    var minAge: Int?
    var maxAge: Int?
    
    init(minAge: Int? = nil, maxAge: Int? = nil) {
        self.minAge = minAge
        self.maxAge = maxAge
    }
    
    var ageRangeText: String {
        switch (minAge, maxAge) {
        case (let min?, let max?):
            return "\(min)-\(max) yaş"
        case (let min?, nil):
            return "\(min)+ yaş"
        case (nil, let max?):
            return "\(max) yaş altı"
        case (nil, nil):
            return "Yaş sınırı yok"
        }
    }
}

struct EventOrganizer: Codable, Hashable {
    var name: String
    var email: String
    var phone: String
    var website: String
    
    init(
        name: String = "",
        email: String = "",
        phone: String = "",
        website: String = ""
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.website = website
    }
}

struct EventPricing: Codable, Hashable {
    var price: Double
    var currency: String
    
    init(price: Double = 0.0, currency: String = "TL") {
        self.price = price
        self.currency = currency
    }
    
    var isFree: Bool {
        price <= 0
    }
    
    var formattedPrice: String {
        if isFree {
            return "Ücretsiz"
        } else {
            return String(format: "%.2f %@", price, currency)
        }
    }
}
