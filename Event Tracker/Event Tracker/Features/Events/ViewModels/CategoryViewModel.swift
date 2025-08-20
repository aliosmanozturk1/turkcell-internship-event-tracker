import Foundation
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var categories: [CategoryModel] = []
    @Published var groups: [GroupModel] = []

    func loadData() async {
        do {
            async let fetchedCategories = try CategoryService.shared.fetchCategories()
            async let fetchedGroups = try CategoryService.shared.fetchGroups()
            categories = try await fetchedCategories
            groups = try await fetchedGroups
        } catch {
            Logger.error("Failed to load categories: \(error)", category: .categories)
        }
    }
}
