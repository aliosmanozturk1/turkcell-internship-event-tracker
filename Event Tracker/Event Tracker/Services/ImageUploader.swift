import UIKit
import FirebaseStorage

final class ImageUploader {
    private static let storage = FirebaseManager.shared.storage
    
    static func upload(images: [UIImage]) async throws -> [EventImage] {
        var uploaded: [EventImage] = []
        let storageRef = storage.reference().child("events")
        for image in images {
            let id = UUID().uuidString
            let mainRef = storageRef.child("images/\(id).jpg")
            let thumbRef = storageRef.child("thumbnails/\(id).jpg")
            let mainData = image.resized(to: 1280).jpegData(compressionQuality: 0.7)
            let thumbData = image.resized(to: 300).jpegData(compressionQuality: 0.3)
            if let mainData, let thumbData {
                _ = try await mainRef.putDataAsync(mainData)
                _ = try await thumbRef.putDataAsync(thumbData)
                let mainURL = try await mainRef.downloadURL()
                let thumbURL = try await thumbRef.downloadURL()
                uploaded.append(EventImage(url: mainURL.absoluteString, thumbnailUrl: thumbURL.absoluteString))
            }
        }
        return uploaded
    }
}
