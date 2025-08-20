//
//  CategorySelector.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 28.07.2025.
//
import SwiftUI


struct CategorySelector: View {
    @Binding var selectedCategories: Set<String>
    @State private var showingCategorySheet = false
    @StateObject private var viewModel = CategoryViewModel()
    
    var selectedCategoryObjects: [(key: String, name: String, icon: String, color: Color)] {
        selectedCategories.compactMap { selected in
            guard let category = viewModel.categories.first(where: { $0.id == selected }) else {
                return nil
            }
            return (key: category.id,
                    name: category.name,
                    icon: category.icon,
                    color: category.swiftUIColor)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Kategoriler")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("*")
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Spacer()
            }
            
            // Category Selection Button
            Button(action: {
                showingCategorySheet = true
            }) {
                HStack {
                    if selectedCategories.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            Text("Kategoriler Seç")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            
                            Text("\(selectedCategories.count) kategori seçildi")
                                .foregroundColor(.primary)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("Düzenle")
                                .foregroundColor(.blue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedCategories.isEmpty ? Color.blue.opacity(0.05) : Color(.systemGray6))
                        .stroke(selectedCategories.isEmpty ? Color.blue.opacity(0.3) : Color.clear,
                               style: StrokeStyle(lineWidth: 1, dash: selectedCategories.isEmpty ? [3] : []))
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Selected Categories Preview
            if !selectedCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedCategoryObjects, id: \.key) { category in
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                
                                Text(category.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(category.color)
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .sheet(isPresented: $showingCategorySheet) {
            CategoryPicker(
                selectedCategories: $selectedCategories,
                categories: viewModel.categories,
                groups: viewModel.groups
            )
        }
        .task {
            await viewModel.loadData()
        }
    }
}
