import Foundation
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    private let firestore = FirebaseManager.shared.firestore
    private init() {}

    private var usersCollection: CollectionReference {
        firestore.collection(FirestoreCollections.users)
    }

    func fetchUser(uid: String) async throws -> UserModel? {
        let document = try await usersCollection.document(uid).getDocument()
        guard let data = document.data() else { return nil }
        let email = data["email"] as? String
        let firstName = data["firstName"] as? String
        let lastName = data["lastName"] as? String
        return UserModel(uid: uid, email: email, firstName: firstName, lastName: lastName)
    }

    func createUser(uid: String, email: String, firstName: String, lastName: String) async throws {
        try await usersCollection.document(uid).setData([
            "email": email,
            "firstName": firstName,
            "lastName": lastName
        ])
    }
}
