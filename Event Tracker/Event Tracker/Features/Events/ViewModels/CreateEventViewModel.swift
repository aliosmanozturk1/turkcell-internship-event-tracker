//
//  CreateEventView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//
import Combine
import SwiftUI

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
    
    
}
