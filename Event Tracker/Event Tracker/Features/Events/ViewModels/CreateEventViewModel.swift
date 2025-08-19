//
//  CreateEventView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI
import UIKit
import FirebaseAuth
import Combine

@MainActor
final class CreateEventViewModel: ObservableObject {
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
    @Published var socialLinks = ""
    @Published var contactInfo = ""
    @Published var selectedImages: [UIImage] = []

    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var isEventCreated = false
    @Published var createdEvent: CreateEventModel?

    func createEvent() async {
        guard let user = AuthService.shared.currentUser else {
            errorMessage = "User not found"
            return
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

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

        let uploadedImages = try? await ImageUploader.upload(images: selectedImages)
        selectedImages.removeAll()

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
            socialLinks: socialLinks,
            contactInfo: contactInfo,
            images: uploadedImages ?? [],
            createdBy: user.uid
        )

        do {
            let savedEvent = try await EventService.shared.createEvent(event)
            createdEvent = savedEvent
            isEventCreated = true
        } catch {
            errorMessage = error.localizedDescription
            isEventCreated = false
        }

    }
    
    func clearForm() {
        title = ""
        description = ""
        selectedCategories = []
        whatToExpected = ""
        startDate = Date()
        endDate = Date().addingTimeInterval(3600)
        registrationDeadline = Date().addingTimeInterval(-86400)
        locationName = ""
        locationAddress1 = ""
        locationAddress2 = ""
        locationCity = ""
        locationDistrict = ""
        locationLatitude = ""
        locationLongitude = ""
        maxParticipants = ""
        currentParticipants = "0"
        showRemaining = true
        minAge = ""
        maxAge = ""
        language = "tr"
        requirements = ""
        organizerName = ""
        organizerEmail = ""
        organizerPhone = ""
        organizerWebsite = ""
        price = "0"
        currency = "TL"
        socialLinks = ""
        contactInfo = ""
        selectedImages = []
        
        errorMessage = nil
        isEventCreated = false
        createdEvent = nil
    }
}
