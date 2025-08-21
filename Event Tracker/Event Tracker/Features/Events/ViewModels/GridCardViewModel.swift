import SwiftUI
import Combine

final class GridCardViewModel: ObservableObject {
    let event: CreateEventModel
    
    init(event: CreateEventModel) {
        self.event = event
    }
    
    var title: String {
        event.title
    }
    
    var imageURL: URL? {
        URL(string: event.images.first?.url ?? "")
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
    
    var locationName: String {
        event.location.name
    }
    
    var categories: [String] {
        event.categories
    }
    
    var formattedPrice: String {
        if event.pricing.price > 0 {
            return "\(Int(event.pricing.price)) \(event.pricing.currency)"
        } else {
            return "Ücretsiz"
        }
    }
    
    var priceColor: Color {
        event.pricing.price > 0 ? .primary : .green
    }
}
