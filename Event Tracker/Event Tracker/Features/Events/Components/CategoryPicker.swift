//
//  CategoryPicker.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 28.07.2025.
//
import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategories: Set<String>
    let categories: [(key: String, name: String, icon: String, color: Color)]
    
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    var filteredCategories: [(key: String, name: String, icon: String, color: Color)] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var categoriesByType: [(String, [(key: String, name: String, icon: String, color: Color)])] {
        [
            ("Yaratıcılık & Sanat", filteredCategories.filter { ["art", "fashion", "theater", "literature", "music"].contains($0.key) }),
            ("Teknoloji & İş", filteredCategories.filter { ["technology", "business", "networking", "workshop"].contains($0.key) }),
            ("Eğlence & Sosyal", filteredCategories.filter { ["party", "festival", "gaming", "film_media"].contains($0.key) }),
            ("Sağlık & Wellness", filteredCategories.filter { ["health_wellness", "sports", "outdoor"].contains($0.key) }),
            ("Eğitim & Gelişim", filteredCategories.filter { ["education", "science"].contains($0.key) }),
            ("Toplum & Yaşam", filteredCategories.filter { ["community", "family", "charity", "politics", "religion_spirituality"].contains($0.key) }),
            ("Diğer", filteredCategories.filter { ["food_drink", "travel"].contains($0.key) })
        ].filter { !$1.isEmpty }
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
                        ForEach(categoriesByType, id: \.0) { sectionTitle, sectionCategories in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(sectionTitle)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 140), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(sectionCategories, id: \.key) { category in
                                FormCategoryCard(
                                            category: category,
                                            isSelected: selectedCategories.contains(category.key)
                                        ) {
                                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                                if selectedCategories.contains(category.key) {
                                                    selectedCategories.remove(category.key)
                                                } else {
                                                    selectedCategories.insert(category.key)
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
