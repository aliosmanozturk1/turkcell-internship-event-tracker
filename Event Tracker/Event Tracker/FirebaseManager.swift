//
//  FirebaseManager.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 10.07.2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    let auth : Auth
    let firestore : Firestore
    let database : Database
    let storage : Storage
    
    private init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.database = Database.database()
        self.storage = Storage.storage()
    }
}

