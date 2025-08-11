//
//  EventView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI
import Combine

struct EventView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var showingSortSheet = false
    @State private var showingFilterSheet = false

    var body: some View {
        VStack(spacing: 0) {
            EventControlsHeader(
                viewModel: viewModel,
                showingSortSheet: $showingSortSheet,
                showingFilterSheet: $showingFilterSheet
            )
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Etkinlikler yükleniyor...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
            } else if viewModel.events.isEmpty {
                Spacer()
                EmptyEventsView()
                Spacer()
            } else {
                EventContentView(viewModel: viewModel)
            }
        }
        .onAppear {
            if viewModel.events.isEmpty {
                Task { await viewModel.loadEvents() }
            }
        }
        .sheet(isPresented: $showingSortSheet) {
            EventSortSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSelectionView(activeFilter: $viewModel.activeFilter)
        }
    }
}

struct EventControlsHeader: View {
    @ObservedObject var viewModel: EventViewModel
    @Binding var showingSortSheet: Bool
    @Binding var showingFilterSheet: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                FilterButton(
                    activeFilterCount: viewModel.activeFilter.activeFilterCount,
                    action: { showingFilterSheet = true }
                )
                
                SortButton(
                    currentSort: viewModel.selectedSortOption,
                    action: { showingSortSheet = true }
                )
                
                Spacer()
                
                ViewToggleButton(
                    selectedView: $viewModel.selectedViewOption
                )
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
}

struct FilterButton: View {
    let activeFilterCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: activeFilterCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .foregroundColor(activeFilterCount > 0 ? .white : .blue)
                
                if activeFilterCount > 0 {
                    Text("Filter (\(activeFilterCount))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                } else {
                    Text("Filter")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(activeFilterCount > 0 ? Color.blue : Color.blue.opacity(0.1))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SortButton: View {
    let currentSort: SortOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: sortIcon)
                    .foregroundColor(.blue)
                
                Text("Sort")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.1))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var sortIcon: String {
        switch currentSort {
        case .dateAscending, .titleAscending, .priceAscending, .participantsAscending:
            return "arrow.up.circle"
        case .dateDescending, .titleDescending, .priceDescending, .participantsDescending:
            return "arrow.down.circle"
        }
    }
}

struct ViewToggleButton: View {
    @Binding var selectedView: ViewOption
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ViewOption.allCases, id: \.self) { option in
                Button(action: {
                    selectedView = option
                }) {
                    Image(systemName: option.icon)
                        .font(.subheadline)
                        .foregroundColor(selectedView == option ? .white : .blue)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedView == option ? Color.blue : Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
        )
    }
}


struct EventContentView: View {
    @ObservedObject var viewModel: EventViewModel
    
    var body: some View {
        ScrollView {
            switch viewModel.selectedViewOption {
            case .list:
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.events) { event in
                        ListCardView(event: event)
                    }
                }
                .padding()
                
            case .grid:
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(viewModel.events) { event in
                        GridCardView(event: event)
                    }
                }
                .padding()
                
            case .compact:
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.events) { event in
                        CompactEventView(event: event)
                    }
                }
                .padding()
            }
        }
    }
}

struct EmptyEventsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("Etkinlik Bulunamadı")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Henüz etkinlik eklenmemiş")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct CompactEventView: View {
    let event: CreateEventModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: event.images.first?.thumbnailUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack {
                    
                    Text(event.startDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(event.pricing.formattedPrice)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(event.pricing.isFree ? .green : .blue)
                        .padding(.trailing, 10)
                    
//                    if !event.participants.isFull {
//                        Text("\(event.participants.remainingSpots) yer kaldı")
//                            .font(.caption)
//                            .foregroundColor(.orange)
//                    } else {
//                        Text("Dolu")
//                            .font(.caption)
//                            .foregroundColor(.red)
//                    }
                }
                
            }
            
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            router.push(.eventDetail(event))
        }
    }
}


#Preview {
    EventView()
}
