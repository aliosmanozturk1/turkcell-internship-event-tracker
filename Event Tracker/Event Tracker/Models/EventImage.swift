import Foundation

struct EventImage: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    let url: String
    let thumbnailUrl: String
}
