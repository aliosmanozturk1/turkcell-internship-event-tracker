//
//  CompleteProfileViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.07.2025.
//

import Combine
import Foundation
import FirebaseAuth
import Firebase

@MainActor
class CompleteProfileViewModel: ObservableObject {
    // Input
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
}
