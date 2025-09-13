//
//  ModernTextEditor.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//
import SwiftUI

// TODO: Change name to FormTextEditor
struct ModernTextEditor: View {
    let title: String
    @Binding var text: String
    let height: CGFloat
    let isRequired: Bool
    
    init(_ title: String, text: Binding<String>, isRequired: Bool = false, height: CGFloat, ) {
            self.title = title
            self._text = text
            self.height = height
            self.isRequired = isRequired
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(minHeight: height)
                
                TextEditor(text: $text)
                    .padding(12)
                    .frame(minHeight: height)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                
                if text.isEmpty {
                    Text("Buraya yazın...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
