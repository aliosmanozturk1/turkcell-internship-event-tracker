//
//  CategoryPicker.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 28.07.2025.
//
import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategories: Set<String>
    let categories: [CategoryModel]
    let groups: [GroupModel]
    
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    var filteredCategories: [CategoryModel] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var categoriesByGroup: [(GroupModel, [CategoryModel])] {
        groups
            .sorted { $0.order < $1.order }
            .compactMap { group in
                let groupCategories = filteredCategories.filter { $0.groupId == group.id }
                return groupCategories.isEmpty ? nil : (group, groupCategories)
            }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Kategori ara...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                    
                    if !selectedCategories.isEmpty {
                        HStack {
                            Text("\(selectedCategories.count) kategori seçildi")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Tümünü Temizle") {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategories.removeAll()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Categories List
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(categoriesByGroup, id: \.0.id) { group, sectionCategories in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(group.name)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    Spacer()
                                }
                                .padding(.horizontal, 20)

                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 140), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(sectionCategories, id: \.id) { category in
                                        FormCategoryCard(
                                            category: (key: category.id,
                                                      name: category.name,
                                                      icon: category.icon,
                                                      color: category.swiftUIColor),
                                            isSelected: selectedCategories.contains(category.id)
                                        ) {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                                if selectedCategories.contains(category.id) {
                                                    selectedCategories.remove(category.id)
                                                } else {
                                                    selectedCategories.insert(category.id)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Kategoriler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
    }
}
