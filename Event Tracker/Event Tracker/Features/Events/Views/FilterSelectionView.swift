//
//  FilterSelectionView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI

struct FilterSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var activeFilter: EventFilter
    @State private var showingCategoryFilter = false
    @State private var showingDateFilter = false
    @State private var showingPriceFilter = false
    @State private var showingLocationFilter = false
    @State private var showingParticipantsFilter = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Filtreleme Seçenekleri")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Etkinlikleri aşağıdaki kriterlere göre filtreleyin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
                
                // Filter Options List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(FilterType.allCases, id: \.self) { filterType in
                            FilterTypeRow(
                                filterType: filterType,
                                filter: activeFilter,
                                onTap: {
                                    handleFilterSelection(filterType)
                                }
                            )
                            
                            if filterType != FilterType.allCases.last {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Bottom Actions
                if activeFilter.isActive {
                    VStack(spacing: 12) {
                        Divider()
                        
                        HStack(spacing: 12) {
                            // Clear All Button
                            Button(action: {
                                activeFilter.clear()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle")
                                        .font(.subheadline)
                                    
                                    Text("Temizle")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .stroke(Color.red, lineWidth: 1)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            // Apply Button
                            Button(action: {
                                dismiss()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.subheadline)
                                    
                                    Text("Uygula (\(activeFilter.activeFilterCount))")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCategoryFilter) {
            CategoryFilterView(selectedCategories: $activeFilter.selectedCategories)
        }
        .sheet(isPresented: $showingDateFilter) {
            DateFilterView(startDate: $activeFilter.startDate, endDate: $activeFilter.endDate)
        }
        .sheet(isPresented: $showingPriceFilter) {
            PriceFilterView(minPrice: $activeFilter.minPrice, maxPrice: $activeFilter.maxPrice)
        }
        .sheet(isPresented: $showingLocationFilter) {
            LocationFilterView(location: $activeFilter.location)
        }
        .sheet(isPresented: $showingParticipantsFilter) {
            ParticipantsFilterView(minParticipants: $activeFilter.minParticipants, maxParticipants: $activeFilter.maxParticipants)
        }
    }
    
    private func handleFilterSelection(_ filterType: FilterType) {
        switch filterType {
        case .category:
            showingCategoryFilter = true
        case .date:
            showingDateFilter = true
        case .price:
            showingPriceFilter = true
        case .location:
            showingLocationFilter = true
        case .participants:
            showingParticipantsFilter = true
        }
    }
}

struct FilterTypeRow: View {
    let filterType: FilterType
    let filter: EventFilter
    let onTap: () -> Void
    
    private var hasActiveFilter: Bool {
        switch filterType {
        case .category:
            return !filter.selectedCategories.isEmpty
        case .date:
            return filter.startDate != nil || filter.endDate != nil
        case .price:
            return filter.minPrice != nil || filter.maxPrice != nil
        case .location:
            return filter.location != nil && !filter.location!.isEmpty
        case .participants:
            return filter.minParticipants != nil || filter.maxParticipants != nil
        }
    }
    
    private var filterSummary: String? {
        switch filterType {
        case .category:
            let count = filter.selectedCategories.count
            return count > 0 ? "\(count) kategori seçili" : nil
        case .date:
            if let start = filter.startDate, let end = filter.endDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
            } else if let start = filter.startDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return "\(formatter.string(from: start)) ve sonrası"
            } else if let end = filter.endDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return "\(formatter.string(from: end)) ve öncesi"
            }
            return nil
        case .price:
            if let min = filter.minPrice, let max = filter.maxPrice {
                return "₺\(Int(min)) - ₺\(Int(max))"
            } else if let min = filter.minPrice {
                return "₺\(Int(min)) ve üzeri"
            } else if let max = filter.maxPrice {
                return "₺\(Int(max)) ve altı"
            }
            return nil
        case .location:
            return filter.location
        case .participants:
            if let min = filter.minParticipants, let max = filter.maxParticipants {
                return "\(min) - \(max) kişi"
            } else if let min = filter.minParticipants {
                return "\(min) kişi ve üzeri"
            } else if let max = filter.maxParticipants {
                return "\(max) kişi ve altı"
            }
            return nil
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: filterType.icon)
                    .font(.title3)
                    .foregroundColor(hasActiveFilter ? .white : .blue)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(hasActiveFilter ? Color.blue : Color.blue.opacity(0.1))
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(filterType.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if hasActiveFilter {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let summary = filterSummary {
                        Text(summary)
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    } else {
                        Text(filterType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FilterSelectionView(activeFilter: .constant(EventFilter()))
}