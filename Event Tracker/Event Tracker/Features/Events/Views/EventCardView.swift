//
//  EventCardView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//


import SwiftUI

struct EventCardView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Banner Image
            AsyncImage(url: URL(string: event.imageURL)) { image in
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
                        
                        Text(formatDate(event.startDateLocal))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(event.locationName)
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
                        
                        Text(event.organizerName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // Price
                    if event.price > 0 {
                        Text("\(Int(event.price)) \(event.currency)")
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
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Bu fonksiyonu kendi tarih formatınıza göre düzenleyin
        // Örnek basit format
        return dateString.prefix(10).replacingOccurrences(of: "-", with: "/")
    }
}

// Event Model
struct Event {
    let id: String
    let title: String
    let categories: [String]
    let startDateLocal: String
    let locationName: String
    let organizerName: String
    let imageURL: String
    let price: Double
    let currency: String
}

// Preview
struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEvent = Event(
            id: "1",
            title: "iOS Developer Meetup - SwiftUI ile Modern Uygulama Geliştirme",
            categories: ["Teknoloji", "Yazılım", "Networking"],
            startDateLocal: "2025-08-15T19:00:00",
            locationName: "ITU Teknokent",
            organizerName: "İstanbul iOS Developers",
            imageURL: "https://example.com/event-image.jpg",
            price: 0,
            currency: "TL"
        )
        
        VStack(spacing: 20) {
            EventCardView(event: sampleEvent)
            
            EventCardView(event: Event(
                id: "2",
                title: "Digital Marketing Summit 2025",
                categories: ["Marketing", "Dijital"],
                startDateLocal: "2025-09-20T09:00:00",
                locationName: "Hilton Convention Center",
                organizerName: "Marketing Pro Events",
                imageURL: "https://example.com/marketing-event.jpg",
                price: 150,
                currency: "TL"
            ))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}