import FirebaseFirestore
import Foundation

final class EventService {
    static let shared = EventService()
    private let firestore = FirebaseManager.shared.firestore
    private init() {}

    private var eventsCollection: CollectionReference {
        firestore.collection("events")
    }

// func createEvent(_ event: CreateEventModel) async throws {
//      try eventsCollection.addDocument(from: event)

    func createEvent(_ event: CreateEventModel) async throws -> CreateEventModel {
        let documentRef = try eventsCollection.addDocument(from: event)
        var eventWithId = event
        eventWithId.id = documentRef.documentID
        return eventWithId
    }

    func fetchEvents() async throws -> [CreateEventModel] {
        let snapshot = try await eventsCollection.getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: CreateEventModel.self)
        }
    }
}
