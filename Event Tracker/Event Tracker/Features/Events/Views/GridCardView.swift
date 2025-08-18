//
//  GridCardView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI

struct GridCardView: View {
    let event: CreateEventModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack(spacing: 0) {
            // Event Image - Top Section
            AsyncImage(url: URL(string: event.images.first?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 12
                        )
                    )
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 12
                        )
                    )
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )
            }
            
            // Event Information - Bottom Section
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(formatDate(event.startDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(event.location.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(event.categories, id: \.self) { category in
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
                
                // Price
                HStack {
                    Spacer()
                    if event.pricing.price > 0 {
                        Text("\(Int(event.pricing.price)) \(event.pricing.currency)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    } else {
                        Text("Ücretsiz")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
        .onTapGesture {
            router.push(.eventDetail(event))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Preview
struct GridCardView_Previews: PreviewProvider {
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
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            GridCardView(event: sampleEvent)
            GridCardView(event: sampleEvent)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
