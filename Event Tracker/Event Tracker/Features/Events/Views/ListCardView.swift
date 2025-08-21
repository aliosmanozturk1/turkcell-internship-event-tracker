//
//  ListCardView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//


import SwiftUI

struct ListCardView: View {
    @StateObject private var viewModel: ListCardViewModel
    @EnvironmentObject private var router: Router
    
    init(event: CreateEventModel) {
        self._viewModel = StateObject(wrappedValue: ListCardViewModel(event: event))
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Event Image - Left Side (Tam yaslı)
            AsyncImage(url: URL(string: viewModel.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 150)
                    .clipped()
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                    )
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 150)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                    )
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )
            }
            
            // Card Content - Right Side
            VStack(alignment: .leading, spacing: 8) {
                // Title - En Üste
                Text(viewModel.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    // .lineLimit(2)
                    .padding(.top, 4)
                    // .fixedSize(horizontal: false, vertical: true)
                
                // Date - Ayrı Satır
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(viewModel.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Location - Ayrı Satır  
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(viewModel.locationName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Organizer
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(viewModel.organizerName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Categories - Scrollable
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Price - Ayrı Satır
                HStack {
                    Spacer()
                    Text(viewModel.priceText)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.priceColor)
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 14)
            .padding(.vertical, 6)
        }
        .frame(height: 150)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .onTapGesture {
            router.push(.eventDetail(viewModel.event))
        }
    }
    
}

// Preview
struct ListCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEvent = CreateEventModel(
            title: "iOS Developer Meetup - SwiftUI ile Modern Uygulama Geliştirme",
            categories: ["Teknoloji", "Yazılım", "Networking"],
            startDate: Date(),
            location: EventLocation(name: "ITU Teknokent"),
            organizer: EventOrganizer(name: "İstanbul iOS Developers"),
            pricing: EventPricing(price: 0, currency: "TL"),
            images: [EventImage(url: "https://example.com/event-image.jpg", thumbnailUrl: "https://example.com/event-image-thumb.jpg")],
            createdBy: "1"
        )
        
        VStack(spacing: 20) {
            ListCardView(event: sampleEvent)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
