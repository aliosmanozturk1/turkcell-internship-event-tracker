//
//  ModernDatePicker.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//
import SwiftUI

// TODO: Change name to FormDatePicker
struct ModernDatePicker: View {
    let title: String
    @Binding var date: Date
    let isRequired: Bool
    
    init(_ title: String, date: Binding<Date>, isRequired: Bool = false) {
        self.title = title
        self._date = date
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
            
            HStack {
                DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}
