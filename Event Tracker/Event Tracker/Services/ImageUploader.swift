import UIKit
import FirebaseStorage

final class ImageUploader {
    private static let storage = FirebaseManager.shared.storage
    
    static func upload(images: [UIImage]) async throws -> [EventImage] {
        let storageRef = storage.reference().child("events")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        return try await withThrowingTaskGroup(of: (EventImage?, Int).self) { group in
            for (index, image) in images.enumerated() {
                group.addTask {
                    let id = UUID().uuidString
                    let mainRef = storageRef.child("images/\(id).jpg")
                    let thumbRef = storageRef.child("thumbnails/\(id).jpg")
                    
                    guard let mainData = await image.resized(to: 1280).jpegData(compressionQuality: 0.7),
                          let thumbData = await image.resized(to: 300).jpegData(compressionQuality: 0.3) else {
                        return (nil, index)
                    }
                    
                    async let mainUpload = mainRef.putDataAsync(mainData, metadata: metadata)
                    async let thumbUpload = thumbRef.putDataAsync(thumbData, metadata: metadata)
                    
                    _ = try await mainUpload
                    _ = try await thumbUpload
                    
                    async let mainURL = mainRef.downloadURL()
                    async let thumbURL = thumbRef.downloadURL()
                    
                    let mainURLResult = try await mainURL
                    let thumbURLResult = try await thumbURL
                    
                    let eventImage = EventImage(url: mainURLResult.absoluteString, thumbnailUrl: thumbURLResult.absoluteString, order: index)
                    return (eventImage, index)
                }
            }
            
            var results: [(EventImage, Int)] = []
            for try await (eventImage, index) in group {
                if let eventImage = eventImage {
                    results.append((eventImage, index))
                }
            }
            
            // Sort by original index to maintain order
            results.sort { $0.1 < $1.1 }
            return results.map { $0.0 }
        }
    }
}
