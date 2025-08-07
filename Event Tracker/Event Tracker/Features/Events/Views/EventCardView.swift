//
//  EventCardView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//


import SwiftUI

struct EventCardView: View {
    let event: CreateEventModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Banner Image
            AsyncImage(url: URL(string: event.images.first?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                    )
            }
            
            // Card Content
            VStack(alignment: .leading, spacing: 12) {
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(event.categories, id: \.self) { category in
                            Text(category)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Title
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
                
                // Date & Location
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(formatDate(event.startDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(event.location.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 16)
                
                // Organizer & Price
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Organizatör")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(event.organizer.name)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // Price
                    if event.pricing.price > 0 {
                        Text("\(Int(event.pricing.price)) \(event.pricing.currency)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    } else {
                        Text("Ücretsiz")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .onTapGesture {
            router.push(.eventDetail(event))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Preview
struct EventCardView_Previews: PreviewProvider {
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
            EventCardView(event: sampleEvent)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
