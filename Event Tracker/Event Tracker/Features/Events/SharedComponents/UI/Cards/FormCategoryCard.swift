//
//  FormCategoryCard.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 28.07.2025.
//

import SwiftUI

struct FormCategoryCard: View {
    let category: (key: String, name: String, icon: String, color: Color)
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    // Icon background - üst radius'ları ana card ile aynı (16)
                    UnevenRoundedRectangle(
                        topLeadingRadius: 16,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 16,
                        style: .continuous
                    )
                    .fill(category.color.opacity(isSelected ? 1.0 : 0.1))
                    .frame(height: 50)
                    
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : category.color)
                    
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(6)
                    }
                }
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? category.color : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    .animation(.easeInOut(duration: 0.2), value: isSelected) // Border için ayrı animasyon
            )
        }
        .buttonStyle(CategoryCardButtonStyle())
    }
}
