//
//  GroupModel.swift
//  Event Tracker
//
//  Created by Claude on 29.07.2025.
//

import Foundation

struct GroupModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let order: Int
}