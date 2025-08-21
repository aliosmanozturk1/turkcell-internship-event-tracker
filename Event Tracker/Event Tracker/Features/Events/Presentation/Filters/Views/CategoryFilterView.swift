//
//  CategoryFilterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI

struct CategoryFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategories: Set<String>
    @StateObject private var viewModel = CategoryFilterViewModel()
    
    let initialSelectedCategories: Set<String>
    
    init(selectedCategories: Binding<Set<String>>) {
        self._selectedCategories = selectedCategories
        self.initialSelectedCategories = selectedCategories.wrappedValue
    }
    
    var hasChanges: Bool {
        selectedCategories != initialSelectedCategories
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with selection info
                if !selectedCategories.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Text("\(selectedCategories.count) kategori seçildi")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button("Tümünü Temizle") {
                                selectedCategories.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Selected categories preview
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(selectedCategories), id: \.self) { categoryId in
                                    if let category = viewModel.categories.first(where: { $0.id == categoryId }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: category.icon)
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                            
                                            Text(category.name)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                            
                                            Button(action: {
                                                selectedCategories.remove(categoryId)
                                            }) {
                                                Image(systemName: "xmark")
                                                    .font(.caption2)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(category.swiftUIColor)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                    }
                }
                
                // Category picker content
                CategoryPickerContent(
                    selectedCategories: $selectedCategories,
                    categories: viewModel.categories,
                    groups: viewModel.groups
                )
            }
            .navigationTitle("Kategori Filtresi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        selectedCategories = initialSelectedCategories
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .disabled(!hasChanges)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// Category picker content extracted from CategoryPicker to reuse the logic
struct CategoryPickerContent: View {
    @Binding var selectedCategories: Set<String>
    let categories: [CategoryModel]
    let groups: [GroupModel]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(groups, id: \.id) { group in
                    CategoryGroupSection(
                        group: group,
                        categories: categories.filter { $0.groupId == group.id },
                        selectedCategories: $selectedCategories
                    )
                }
            }
            .padding()
        }
    }
}

struct CategoryGroupSection: View {
    let group: GroupModel
    let categories: [CategoryModel]
    @Binding var selectedCategories: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Group header
            HStack {
                Text(group.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(categories.filter { selectedCategories.contains($0.id) }.count)/\(categories.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
            }
            
            // Categories grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(categories, id: \.id) { category in
                    CategoryFilterCard(
                        category: category,
                        isSelected: selectedCategories.contains(category.id),
                        onTap: {
                            if selectedCategories.contains(category.id) {
                                selectedCategories.remove(category.id)
                            } else {
                                selectedCategories.insert(category.id)
                            }
                        }
                    )
                }
            }
        }
    }
}

struct CategoryFilterCard: View {
    let category: CategoryModel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : category.swiftUIColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? category.swiftUIColor : category.swiftUIColor.opacity(0.1))
                    )
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.swiftUIColor.opacity(0.1) : Color(.systemGray6))
                    .stroke(isSelected ? category.swiftUIColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    CategoryFilterView(selectedCategories: .constant(Set(["music", "technology"])))
}
