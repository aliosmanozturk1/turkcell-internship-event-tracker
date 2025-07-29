//
//  CreateEventView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI
import FirebaseAuth

@MainActor
class CreateEventViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedCategories: Set<String> = []
    @Published var whatToExpected = ""
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(3600)
    @Published var registrationDeadline = Date().addingTimeInterval(-86400)
    @Published var locationName = ""
    @Published var locationAddress1 = ""
    @Published var locationAddress2 = ""
    @Published var locationCity = ""
    @Published var locationDistrict = ""
    @Published var locationLatitude = ""
    @Published var locationLongitude = ""
    @Published var maxParticipants = ""
    @Published var currentParticipants = "0"
    @Published var showRemaining = true
    @Published var minAge = ""
    @Published var maxAge = ""
    @Published var language = "tr"
    @Published var requirements = ""
    @Published var organizerName = ""
    @Published var organizerEmail = ""
    @Published var organizerPhone = ""
    @Published var organizerWebsite = ""
    @Published var price = "0"
    @Published var currency = "TL"
    @Published var status = "active"
    @Published var socialLinks = ""
    @Published var contactInfo = ""
    @Published var imageURL = ""
    @Published var hasGalleryImages = false

    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var isEventCreated = false

    func createEvent() async {
        guard let user = AuthService.shared.currentUser else {
            errorMessage = "User not found"
            return
        }

        isSaving = true
        errorMessage = nil

        let location = EventLocation(
            name: locationName,
            address1: locationAddress1,
            address2: locationAddress2,
            city: locationCity,
            district: locationDistrict,
            latitude: locationLatitude,
            longitude: locationLongitude
        )

        let participants = EventParticipants(
            maxParticipants: Int(maxParticipants) ?? 0,
            currentParticipants: Int(currentParticipants) ?? 0,
            showRemaining: showRemaining
        )

        let ageRestriction = AgeRestriction(
            minAge: Int(minAge),
            maxAge: Int(maxAge)
        )

        let organizer = EventOrganizer(
            name: organizerName,
            email: organizerEmail,
            phone: organizerPhone,
            website: organizerWebsite
        )

        let pricing = EventPricing(
            price: Double(price) ?? 0,
            currency: currency
        )

        guard let eventStatus = EventStatus(rawValue: status) else {
            errorMessage = "Invalid status"
            isSaving = false
            return
        }

        let event = CreateEventModel(
            title: title,
            description: description,
            categories: Array(selectedCategories),
            whatToExpected: whatToExpected,
            startDate: startDate,
            endDate: endDate,
            registrationDeadline: registrationDeadline,
            location: location,
            participants: participants,
            ageRestriction: ageRestriction,
            language: language,
            requirements: requirements,
            organizer: organizer,
            pricing: pricing,
            status: eventStatus,
            socialLinks: socialLinks,
            contactInfo: contactInfo,
            imageURL: imageURL,
            hasGalleryImages: hasGalleryImages,
            createdBy: user.uid
        )

        do {
            try await EventService.shared.createEvent(event)
            isEventCreated = true
        } catch {
            errorMessage = error.localizedDescription
            isEventCreated = false
        }

        isSaving = false
    }
}
