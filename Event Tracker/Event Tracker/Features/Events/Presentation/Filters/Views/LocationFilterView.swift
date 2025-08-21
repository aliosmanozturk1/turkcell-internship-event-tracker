//
//  LocationFilterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI

struct LocationFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: LocationFilterViewModel
    @Binding var location: String?
    @FocusState private var isLocationFieldFocused: Bool
    
    init(location: Binding<String?>) {
        self._location = location
        self._viewModel = StateObject(wrappedValue: LocationFilterViewModel(
            location: location.wrappedValue
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Konum Filtresi")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Etkinlikleri konuma göre filtreleyin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick location presets
                        LocationPresetsSection(viewModel: viewModel)
                        
                        Divider()
                        
                        // Custom location search
                        VStack(spacing: 20) {
                            Text("Özel Konum Arama")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Konum")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.blue)
                                    
                                    TextField("Şehir, ilçe veya mekan adı girin...", text: $viewModel.tempLocation)
                                        .focused($isLocationFieldFocused)
                                        .onChange(of: isLocationFieldFocused) { _, editing in
                                            if editing {
                                                viewModel.clearPresetSelection()
                                            }
                                        }
                                    
                                    if !viewModel.tempLocation.isEmpty {
                                        Button(action: {
                                            viewModel.clearFilter()
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            }
                            
                            // Search tips
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Arama İpuçları:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• Şehir adı: \"İstanbul\", \"Ankara\"")
                                    Text("• İlçe adı: \"Kadıköy\", \"Çankaya\"")
                                    Text("• Mekan adı: \"Zorlu Center\", \"AKM\"")
                                    Text("• Adres parçası: \"Bağdat Caddesi\"")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.05))
                            )
                        }
                        .padding(.horizontal)
                        
                        // Clear button
                        if !viewModel.tempLocation.isEmpty {
                            Button(action: {
                                viewModel.clearFilter()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.subheadline)
                                    
                                    Text("Konum Filtresini Temizle")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .stroke(Color.red, lineWidth: 1)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Konum Filtresi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        viewModel.applyChanges()
                        location = viewModel.location
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .disabled(!viewModel.hasChanges)
                }
            }
        }
    }
}

struct LocationPresetsSection: View {
    @ObservedObject var viewModel: LocationFilterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popüler Şehirler")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(LocationPreset.allCases, id: \.self) { preset in
                    Button(action: {
                        viewModel.applyPreset(preset)
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: preset.icon)
                                .font(.title2)
                                .foregroundColor(viewModel.selectedPreset == preset ? .white : .blue)
                            
                            Text(preset.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(viewModel.selectedPreset == preset ? .white : .primary)
                                .multilineTextAlignment(.center)
                            
                            Text(preset.description)
                                .font(.caption)
                                .foregroundColor(viewModel.selectedPreset == preset ? .white.opacity(0.8) : .secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.selectedPreset == preset ? Color.blue : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}


#Preview {
    LocationFilterView(location: .constant(nil))
}