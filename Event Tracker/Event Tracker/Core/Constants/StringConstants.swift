//
//  StringConstants.swift
//  Event Tracker
//
//  Centralized string constants for error messages, UI strings, and other text literals
//

import Foundation

enum StringConstants {
    
    // MARK: - Error Messages
    enum ErrorMessages {
        static let emailCannotBeEmpty = "Email cannot be empty."
        static let passwordCannotBeEmpty = "Password cannot be empty."
        static let passwordsDoNotMatch = "Passwords do not match."
        static let appleSignInFailed = "Apple Sign-In failed"
        static let eventNotFound = "Event not found"
        static let eventIsFull = "Event is full"
        static let transactionFailed = "Transaction failed"
        
        // Auth Service Errors
        static let userNotFound = "User not found"
        static let invalidCredentials = "Invalid user credentials"
        static let networkError = "Please check your internet connection"
        static let applicationViewNotFound = "Application view not found"
        static let googleAuthError = "Google authentication error"
        static let unknownError = "An unknown error occurred"
    }
    
    // MARK: - UI Strings
    enum UI {
        static let free = "Ücretsiz"
        static let noAgeRestriction = "Yaş sınırı yok"
        static let ageUnder = "yaş altı"
        static let agePlus = "yaş"
        static let ageRange = "yaş"
        static let defaultCurrency = "TL"
        static let defaultLanguage = "tr"
    }
    
    // MARK: - Firestore Field Names
    enum FirestoreFields {
        static let createdEvents = "createdEvents"
        static let joinedEvents = "joinedEvents"
        static let participants = "participants"
        static let currentParticipants = "currentParticipants"
        static let maxParticipants = "maxParticipants"
        static let createdBy = "createdBy"
    }
}