//
//  ModernPicker.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//
import SwiftUI

// TODO: Change name to FormPicker
struct ModernPicker: View {
    let title: String
    @Binding var selection: String
    let options: [(String, String)]
    let isRequired: Bool
    
    init(_ title: String, selection: Binding<String>, options: [(String, String)], isRequired: Bool = false) {
        self.title = title
        self._selection = selection
        self.options = options
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
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}
