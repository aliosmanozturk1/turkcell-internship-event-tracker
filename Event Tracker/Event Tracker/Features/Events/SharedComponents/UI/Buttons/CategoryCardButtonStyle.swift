//
//  CategoryCardButtonStyle.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 28.07.2025.
//

import SwiftUI

struct CategoryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
