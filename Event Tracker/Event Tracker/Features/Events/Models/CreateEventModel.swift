//
//  CreateEventModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 29.07.2025.
//

import Foundation
import FirebaseFirestore

struct CreateEventModel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var categories: [String]
    var whatToExpected: String
    var startDate: Date
    var endDate: Date
    var registrationDeadline: Date
    var location: EventLocation
    var participants: EventParticipants
    var ageRestriction: AgeRestriction
    var language: String
    var requirements: String
    var organizer: EventOrganizer
    var pricing: EventPricing
    var socialLinks: String
    var contactInfo: String
    var images: [EventImage]
    var createdAt: Date
    var updatedAt: Date
    var createdBy: String
    
    init(
        title: String = "",
        description: String = "",
        categories: [String] = [],
        whatToExpected: String = "",
        startDate: Date = Date().addingTimeInterval(86400),
        endDate: Date = Date().addingTimeInterval(90000),
        registrationDeadline: Date = Date().addingTimeInterval(82800),
        location: EventLocation = EventLocation(),
        participants: EventParticipants = EventParticipants(),
        ageRestriction: AgeRestriction = AgeRestriction(),
        language: String = "tr",
        requirements: String = "",
        organizer: EventOrganizer = EventOrganizer(),
        pricing: EventPricing = EventPricing(),
        socialLinks: String = "",
        contactInfo: String = "",
        images: [EventImage] = [],
        createdBy: String = ""
    ) {
        self.title = title
        self.description = description
        self.categories = categories
        self.whatToExpected = whatToExpected
        self.startDate = startDate
        self.endDate = endDate
        self.registrationDeadline = registrationDeadline
        self.location = location
        self.participants = participants
        self.ageRestriction = ageRestriction
        self.language = language
        self.requirements = requirements
        self.organizer = organizer
        self.pricing = pricing
        self.socialLinks = socialLinks
        self.contactInfo = contactInfo
        self.images = images
        self.createdAt = Date()
        self.updatedAt = Date()
        self.createdBy = createdBy
    }
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
