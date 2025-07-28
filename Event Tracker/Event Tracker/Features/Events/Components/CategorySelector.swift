//
//  CategorySelector.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 28.07.2025.
//
import SwiftUI


struct CategorySelector: View {
    @Binding var selectedCategories: Set<String>
    @State private var searchText = ""
    @State private var showingCategorySheet = false
    
    let categories: [(key: String, name: String, icon: String, color: Color)] = [
        ("art", "Sanat", "paintbrush.fill", .purple),
        ("business", "İş", "briefcase.fill", .blue),
        ("charity", "Hayırseverlik", "heart.fill", .pink),
        ("community", "Topluluk", "person.3.fill", .orange),
        ("education", "Eğitim", "graduationcap.fill", .indigo),
        ("family", "Aile", "house.fill", .green),
        ("fashion", "Moda", "tshirt.fill", .purple),
        ("festival", "Festival", "party.popper.fill", .yellow),
        ("film_media", "Film & Medya", "tv.fill", .red),
        ("food_drink", "Yemek & İçecek", "fork.knife", .orange),
        ("gaming", "Oyun", "gamecontroller.fill", .blue),
        ("health_wellness", "Sağlık", "heart.circle.fill", .green),
        ("literature", "Edebiyat", "book.fill", .brown),
        ("music", "Müzik", "music.note", .purple),
        ("networking", "Networking", "link", .blue),
        ("outdoor", "Açık Hava", "tree.fill", .green),
        ("party", "Parti", "balloon.fill", .pink),
        ("politics", "Politika", "building.columns.fill", .gray),
        ("religion_spirituality", "Din & Maneviyat", "moon.stars.fill", .indigo),
        ("science", "Bilim", "atom", .cyan),
        ("sports", "Spor", "sportscourt.fill", .orange),
        ("technology", "Teknoloji", "laptopcomputer", .blue),
        ("theater", "Tiyatro", "theatermasks.fill", .red),
        ("travel", "Seyahat", "airplane", .blue),
        ("workshop", "Atölye", "hammer.fill", .gray)
    ]
    
    var selectedCategoryObjects: [(key: String, name: String, icon: String, color: Color)] {
        selectedCategories.compactMap { selected in
            categories.first { $0.key == selected }
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
                categories: categories
            )
        }
    }
}
