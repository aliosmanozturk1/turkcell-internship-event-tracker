//
//  EventSortSheet.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI
import Combine

struct EventSortSheet: View {
    @ObservedObject var viewModel: EventViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(SortOption.allCases, id: \.self) { option in
                    SortOptionRow(
                        option: option,
                        isSelected: viewModel.selectedSortOption == option
                    ) {
                        viewModel.selectedSortOption = option
                        dismiss()
                    }
                }
            }
            .navigationTitle("Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct SortOptionRow: View {
    let option: SortOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(sortDescription(for: option))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sortDescription(for option: SortOption) -> String {
        switch option {
        case .dateAscending:
            return "En eski tarihli etkinlikler önce"
        case .dateDescending:
            return "En yeni tarihli etkinlikler önce"
        case .titleAscending:
            return "Alfabetik sıra (A-Z)"
        case .titleDescending:
            return "Alfabetik sıra (Z-A)"
        case .priceAscending:
            return "Önce ücretsiz, sonra en ucuzdan pahalıya"
        case .priceDescending:
            return "En pahalıdan en ucuza"
        case .participantsAscending:
            return "En az katılımcılı etkinlikler önce"
        case .participantsDescending:
            return "En çok katılımcılı etkinlikler önce"
        }
    }
}
