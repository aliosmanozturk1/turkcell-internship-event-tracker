import SwiftUI
import Combine

final class CompactCardViewModel: ObservableObject {
    let event: CreateEventModel
    
    init(event: CreateEventModel) {
        self.event = event
    }
    
    var title: String {
        event.title
    }
    
    var thumbnailImageURL: URL? {
        URL(string: event.images.first?.thumbnailUrl ?? "")
    }
    
    var formattedDate: String {
        event.startDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    var formattedPrice: String {
        event.pricing.formattedPrice
    }
    
    var priceColor: Color {
        event.pricing.isFree ? .green : .blue
    }
}
