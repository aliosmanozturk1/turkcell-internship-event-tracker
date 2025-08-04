import UIKit
import FirebaseStorage

final class ImageStorageService {
    static let shared = ImageStorageService()
    private let storage = FirebaseManager.shared.storage

    private init() {}

    func uploadImages(_ images: [UIImage]) async throws -> [EventImage] {
        var uploaded: [EventImage] = []
        for image in images {
            let id = UUID().uuidString
            let full = image.resized(toMaxDimension: 1024)
            let thumb = image.resized(toMaxDimension: 300)

            guard let fullData = full.jpegData(compressionQuality: 0.8),
                  let thumbData = thumb.jpegData(compressionQuality: 0.6) else { continue }

            let fullRef = storage.reference().child("events/\(id).jpg")
            let thumbRef = storage.reference().child("events/\(id)_thumb.jpg")

            try await putData(fullRef, data: fullData)
            try await putData(thumbRef, data: thumbData)

            let fullURL = try await downloadURL(fullRef)
            let thumbURL = try await downloadURL(thumbRef)

            uploaded.append(EventImage(url: fullURL.absoluteString, thumbnailURL: thumbURL.absoluteString))
        }
        return uploaded
    }

    private func putData(_ ref: StorageReference, data: Data) async throws {
        try await withCheckedThrowingContinuation { continuation in
            ref.putData(data, metadata: nil) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func downloadURL(_ ref: StorageReference) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            ref.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                }
            }
        }
    }
}

