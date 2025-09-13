//
//  FormSectionCard.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 28.07.2025.
//

import SwiftUI

// TODO: Change name to FormSectionCard
struct FormSectionCard<Content: View>: View {
    let title: String
    let isRequired: Bool
    let icon: String
    let content: Content
    
    init(title: String, isRequired: Bool = false, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.isRequired = isRequired
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                
                Spacer()
            }
            
            content
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}
