import FirebaseFirestore
import Foundation

final class EventService {
    static let shared = EventService()
    private let firestore = FirebaseManager.shared.firestore
    private init() {}

    private var eventsCollection: CollectionReference {
        firestore.collection("events")
    }

    func createEvent(_ event: CreateEventModel) async throws -> CreateEventModel {
        let documentRef = try eventsCollection.addDocument(from: event)
        var eventWithId = event
        eventWithId.id = documentRef.documentID

        // Record under creator's profile for convenience
        if !event.createdBy.isEmpty {
            do {
                try await usersCollection.document(event.createdBy)
                    .setData(["createdEvents": FieldValue.arrayUnion([documentRef.documentID])], merge: true)
            } catch {
                // Non-fatal: event is created even if this fails
                print("Failed to record created event for user: \(error.localizedDescription)")
            }
        }

        return eventWithId
    }

    func fetchEvents() async throws -> [CreateEventModel] {
        let snapshot = try await eventsCollection.getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: CreateEventModel.self)
        }
    }

    // MARK: - Participation (Join / Leave)

    private var usersCollection: CollectionReference { firestore.collection("users") }

    /// Checks whether a given user has already joined the event.
    func isUserJoined(eventId: String, userId: String) async throws -> Bool {
        let userDoc = try await usersCollection.document(userId).getDocument()
        guard let data = userDoc.data() else { return false }
        let joined = data["joinedEvents"] as? [String] ?? []
        return joined.contains(eventId)
    }

    /// Atomically joins a user to an event and increments currentParticipants using a Firestore transaction.
    /// Returns the updated `currentParticipants` count.
    func joinEvent(eventId: String, userId: String) async throws -> Int {
        let eventRef = eventsCollection.document(eventId)
        let userRef = usersCollection.document(userId)

        let resultAny = try await firestore.runTransaction { transaction, errorPointer -> Any? in
            // Helper to set error and return nil
            func fail(_ code: Int, _ message: String) -> Any? {
                errorPointer?.pointee = NSError(domain: "EventService", code: code, userInfo: [NSLocalizedDescriptionKey: message])
                return nil
            }

            // Read event and user documents
            let eventSnapshot: DocumentSnapshot
            let userSnapshot: DocumentSnapshot
            do {
                eventSnapshot = try transaction.getDocument(eventRef)
                userSnapshot = try transaction.getDocument(userRef)
            } catch let nsErr as NSError {
                errorPointer?.pointee = nsErr
                return nil
            }

            guard let eventData = eventSnapshot.data() else {
                return fail(404, "Event not found")
            }

            var userData = userSnapshot.data() ?? [:]
            var joinedEvents = userData["joinedEvents"] as? [String] ?? []

            // Prevent double-join
            if joinedEvents.contains(eventId) {
                let participants = eventData["participants"] as? [String: Any]
                let current = participants?["currentParticipants"] as? Int ?? 0
                return current
            }

            // Capacity check
            let participants = eventData["participants"] as? [String: Any] ?? [:]
            let maxParticipants = participants["maxParticipants"] as? Int ?? 0
            let currentParticipants = participants["currentParticipants"] as? Int ?? 0
            if maxParticipants > 0, currentParticipants >= maxParticipants {
                return fail(409, "Event is full")
            }

            // Update event count
            let newCount = currentParticipants + 1
            transaction.updateData(["participants.currentParticipants": newCount], forDocument: eventRef)

            // Update or create user joined list
            if userSnapshot.exists {
                transaction.updateData(["joinedEvents": FieldValue.arrayUnion([eventId])], forDocument: userRef)
            } else {
                transaction.setData(["joinedEvents": [eventId]], forDocument: userRef, merge: true)
            }

            return newCount
        }

        guard let updatedCount = resultAny as? Int else {
            throw NSError(domain: "EventService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Transaction failed"])
        }
        return updatedCount
    }

    /// Atomically removes a user's participation from an event and decrements currentParticipants.
    /// Returns the updated `currentParticipants` count.
    func leaveEvent(eventId: String, userId: String) async throws -> Int {
        let eventRef = eventsCollection.document(eventId)
        let userRef = usersCollection.document(userId)

        let resultAny = try await firestore.runTransaction { transaction, errorPointer -> Any? in
            func fail(_ code: Int, _ message: String) -> Any? {
                errorPointer?.pointee = NSError(domain: "EventService", code: code, userInfo: [NSLocalizedDescriptionKey: message])
                return nil
            }

            // Read event and user documents
            let eventSnapshot: DocumentSnapshot
            let userSnapshot: DocumentSnapshot
            do {
                eventSnapshot = try transaction.getDocument(eventRef)
                userSnapshot = try transaction.getDocument(userRef)
            } catch let nsErr as NSError {
                errorPointer?.pointee = nsErr
                return nil
            }

            guard let eventData = eventSnapshot.data() else {
                return fail(404, "Event not found")
            }

            let userData = userSnapshot.data() ?? [:]
            let joinedEvents = userData["joinedEvents"] as? [String] ?? []

            // If not joined, nothing to do
            if !joinedEvents.contains(eventId) {
                let participants = eventData["participants"] as? [String: Any]
                let current = participants?["currentParticipants"] as? Int ?? 0
                return current
            }

            // Decrement count safely
            let participants = eventData["participants"] as? [String: Any] ?? [:]
            let currentParticipants = participants["currentParticipants"] as? Int ?? 0
            let newCount = max(0, currentParticipants - 1)
            transaction.updateData(["participants.currentParticipants": newCount], forDocument: eventRef)

            // Remove from user joined list
            transaction.updateData(["joinedEvents": FieldValue.arrayRemove([eventId])], forDocument: userRef)

            return newCount
        }

        guard let updatedCount = resultAny as? Int else {
            throw NSError(domain: "EventService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Transaction failed"])
        }
        return updatedCount
    }

    // MARK: - User-specific event queries

    func fetchEventsCreatedBy(userId: String) async throws -> [CreateEventModel] {
        let snapshot = try await eventsCollection
            .whereField("createdBy", isEqualTo: userId)
            .getDocuments()
        let events = snapshot.documents.compactMap { try? $0.data(as: CreateEventModel.self) }
        return events
    }

    func fetchEvents(withIds ids: [String]) async throws -> [CreateEventModel] {
        guard !ids.isEmpty else { return [] }
        // Firestore 'in' supports up to 10 items; chunk if necessary
        let chunks: [[String]] = stride(from: 0, to: ids.count, by: 10).map {
            Array(ids[$0..<min($0 + 10, ids.count)])
        }
        var results: [CreateEventModel] = []
        for chunk in chunks {
            let snapshot = try await eventsCollection
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            let items = snapshot.documents.compactMap { try? $0.data(as: CreateEventModel.self) }
            results.append(contentsOf: items)
        }
        return results
    }

    func fetchJoinedEvents(for userId: String) async throws -> [CreateEventModel] {
        let userDoc = try await usersCollection.document(userId).getDocument()
        let joinedIds = (userDoc.data()? ["joinedEvents"] as? [String]) ?? []
        return try await fetchEvents(withIds: joinedIds)
    }
    
    // MARK: - Delete Event
    
    func deleteEvent(id: String) async throws {
        let eventRef = eventsCollection.document(id)
        
        // Get event data before deleting to clean up user references
        let eventSnapshot = try await eventRef.getDocument()
        guard let eventData = eventSnapshot.data() else {
            throw NSError(domain: "EventService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found"])
        }
        
        let createdBy = eventData["createdBy"] as? String ?? ""
        
        // Delete the event document
        try await eventRef.delete()
        
        // Clean up creator's createdEvents list if needed
        if !createdBy.isEmpty {
            try await usersCollection.document(createdBy)
                .updateData(["createdEvents": FieldValue.arrayRemove([id])])
        }
    }
}
