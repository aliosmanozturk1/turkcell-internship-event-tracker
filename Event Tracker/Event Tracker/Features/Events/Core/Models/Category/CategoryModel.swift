//
//  CategoryModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 29.07.2025.
//

import Foundation
import SwiftUI

struct CategoryModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let color: String
    let groupId: String
    
    /// SwiftUI Color from hex string using existing Color+Hex extension
    var swiftUIColor: Color {
        Color(hex: color)
    }
}
