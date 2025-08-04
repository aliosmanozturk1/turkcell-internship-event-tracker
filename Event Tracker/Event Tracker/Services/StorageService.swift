import Foundation
import FirebaseStorage
import UIKit

final class StorageService {
    static let shared = StorageService()
    private let storage = FirebaseManager.shared.storage
    private init() {}

    func uploadEventImages(_ images: [UIImage], eventId: String) async throws -> ([String], [String]) {
        var imageURLs: [String] = []
        var thumbnailURLs: [String] = []

        for image in images {
            let uuid = UUID().uuidString
            let imageRef = storage.reference().child("events/\(eventId)/\(uuid).jpg")
            let thumbRef = storage.reference().child("events/\(eventId)/\(uuid)_thumb.jpg")

            let resized = image.resized(toMax: 1280)
            if let data = resized.jpegData(compressionQuality: 0.8) {
                _ = try await imageRef.putDataAsync(data, metadata: nil)
                let url = try await imageRef.downloadURL()
                imageURLs.append(url.absoluteString)
            }

            let thumbImage = image.resized(toMax: 300)
            if let thumbData = thumbImage.jpegData(compressionQuality: 0.6) {
                _ = try await thumbRef.putDataAsync(thumbData, metadata: nil)
                let thumbURL = try await thumbRef.downloadURL()
                thumbnailURLs.append(thumbURL.absoluteString)
            }
        }

        return (imageURLs, thumbnailURLs)
    }
}

