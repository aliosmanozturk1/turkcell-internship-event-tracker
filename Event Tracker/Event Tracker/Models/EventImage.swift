import Foundation

struct EventImage: Identifiable, Codable {
    var id: String = UUID().uuidString
    let url: String
    let thumbnailUrl: String
}
