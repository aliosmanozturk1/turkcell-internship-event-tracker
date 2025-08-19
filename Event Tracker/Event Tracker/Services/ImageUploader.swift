import UIKit
import FirebaseStorage

final class ImageUploader {
    private static let storage = FirebaseManager.shared.storage
    
    static func upload(images: [UIImage]) async throws -> [EventImage] {
        let storageRef = storage.reference().child("events")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        return try await withThrowingTaskGroup(of: EventImage?.self) { group in
            for image in images {
                group.addTask {
                    let id = UUID().uuidString
                    let mainRef = storageRef.child("images/\(id).jpg")
                    let thumbRef = storageRef.child("thumbnails/\(id).jpg")
                    
                    guard let mainData = await image.resized(to: 1280).jpegData(compressionQuality: 0.7),
                          let thumbData = await image.resized(to: 300).jpegData(compressionQuality: 0.3) else {
                        return nil
                    }
                    
                    async let mainUpload = mainRef.putDataAsync(mainData, metadata: metadata)
                    async let thumbUpload = thumbRef.putDataAsync(thumbData, metadata: metadata)
                    
                    _ = try await mainUpload
                    _ = try await thumbUpload
                    
                    async let mainURL = mainRef.downloadURL()
                    async let thumbURL = thumbRef.downloadURL()
                    
                    let mainURLResult = try await mainURL
                    let thumbURLResult = try await thumbURL
                    
                    return EventImage(url: mainURLResult.absoluteString, thumbnailUrl: thumbURLResult.absoluteString)
                }
            }
            
            var results: [EventImage] = []
            for try await result in group {
                if let eventImage = result {
                    results.append(eventImage)
                }
            }
            return results
        }
    }
}
