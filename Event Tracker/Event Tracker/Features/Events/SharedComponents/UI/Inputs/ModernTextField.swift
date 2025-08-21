//
//  ModernTextField.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//
import SwiftUI

// TODO: Change name to FormTextField
struct ModernTextField: View {
    let title: String
    @Binding var text: String
    let isRequired: Bool
    
    init(_ title: String, text: Binding<String>, isRequired: Bool = false) {
        self.title = title
        self._text = text
        self.isRequired = isRequired
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
            }
            
            TextField("", text: $text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(text.isEmpty && isRequired ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        }
    }
}
