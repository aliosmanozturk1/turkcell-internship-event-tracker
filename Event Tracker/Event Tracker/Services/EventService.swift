import Foundation
import FirebaseFirestore

final class EventService {
    static let shared = EventService()
    private let firestore = FirebaseManager.shared.firestore
    private init() {}

    private var eventsCollection: CollectionReference {
        firestore.collection("events")
    }

    func generateEventID() -> String {
        eventsCollection.document().documentID
    }

    func createEvent(_ event: CreateEventModel, id: String? = nil) async throws {
        if let id = id {
            try eventsCollection.document(id).setData(from: event)
        } else {
            try eventsCollection.addDocument(from: event)
        }
    }

    func fetchEvents() async throws -> [CreateEventModel] {
        let snapshot = try await eventsCollection.getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: CreateEventModel.self)
        }
    }
}
