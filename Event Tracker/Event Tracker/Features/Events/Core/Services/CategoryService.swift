import Foundation
import FirebaseFirestore

final class CategoryService {
    static let shared = CategoryService()
    private let firestore = FirebaseManager.shared.firestore
    private init() {}

    private var categoriesCollection: CollectionReference {
        firestore.collection(FirestoreCollections.categories)
    }

    private var groupsCollection: CollectionReference {
        firestore.collection(FirestoreCollections.groups)
    }

    func fetchCategories() async throws -> [CategoryModel] {
        let snapshot = try await categoriesCollection.getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard
                let name = data["name"] as? String,
                let icon = data["icon"] as? String,
                let color = data["color"] as? String,
                let groupId = data["groupId"] as? String
            else { return nil }

            return CategoryModel(id: doc.documentID,
                                 name: name,
                                 icon: icon,
                                 color: color,
                                 groupId: groupId)
        }
    }

    func fetchGroups() async throws -> [GroupModel] {
        let snapshot = try await groupsCollection.getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard
                let name = data["name"] as? String,
                let order = data["order"] as? Int
            else { return nil }

            return GroupModel(id: doc.documentID,
                              name: name,
                              order: order)
        }
    }
}
