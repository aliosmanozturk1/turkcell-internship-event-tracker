//
//  LocationFilterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI

struct LocationFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var location: String?
    
    @State private var tempLocation: String
    @State private var selectedPreset: LocationPreset?
    @FocusState private var isLocationFieldFocused: Bool
    
    private let initialLocation: String?
    
    init(location: Binding<String?>) {
        self._location = location
        self.initialLocation = location.wrappedValue
        self._tempLocation = State(initialValue: location.wrappedValue ?? "")
    }
    
    private var hasChanges: Bool {
        let newValue = tempLocation.isEmpty ? nil : tempLocation
        return newValue != initialLocation
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
                        LocationPresetsSection(
                            selectedPreset: $selectedPreset,
                            tempLocation: $tempLocation
                        )
                        
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
                                    
                                    TextField("Şehir, ilçe veya mekan adı girin...", text: $tempLocation)
                                        .focused($isLocationFieldFocused)
                                        .onChange(of: isLocationFieldFocused) { editing in
                                            // Kullanıcı yazmaya başladığında preset seçimini temizle
                                            if editing {
                                                selectedPreset = nil
                                            }
                                        }
                                    
                                    if !tempLocation.isEmpty {
                                        Button(action: {
                                            tempLocation = ""
                                            selectedPreset = nil
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
                        if !tempLocation.isEmpty {
                            Button(action: {
                                tempLocation = ""
                                selectedPreset = nil
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
                        location = tempLocation.isEmpty ? nil : tempLocation
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .disabled(!hasChanges)
                }
            }
        }
    }
}

struct LocationPresetsSection: View {
    @Binding var selectedPreset: LocationPreset?
    @Binding var tempLocation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popüler Şehirler")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(LocationPreset.allCases, id: \.self) { preset in
                    Button(action: {
                        selectedPreset = preset
                        tempLocation = preset.locationName
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: preset.icon)
                                .font(.title2)
                                .foregroundColor(selectedPreset == preset ? .white : .blue)
                            
                            Text(preset.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedPreset == preset ? .white : .primary)
                                .multilineTextAlignment(.center)
                            
                            Text(preset.description)
                                .font(.caption)
                                .foregroundColor(selectedPreset == preset ? .white.opacity(0.8) : .secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPreset == preset ? Color.blue : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

enum LocationPreset: String, CaseIterable {
    case istanbul = "istanbul"
    case ankara = "ankara"
    case izmir = "izmir"
    case bursa = "bursa"
    case antalya = "antalya"
    case adana = "adana"
    
    var displayName: String {
        switch self {
        case .istanbul: return "İstanbul"
        case .ankara: return "Ankara"
        case .izmir: return "İzmir"
        case .bursa: return "Bursa"
        case .antalya: return "Antalya"
        case .adana: return "Adana"
        }
    }
    
    var description: String {
        switch self {
        case .istanbul: return "Türkiye'nin en büyük şehri"
        case .ankara: return "Türkiye'nin başkenti"
        case .izmir: return "Ege'nin incisi"
        case .bursa: return "Yeşil Bursa"
        case .antalya: return "Turizm başkenti"
        case .adana: return "Çukurova'nın merkezi"
        }
    }
    
    var icon: String {
        switch self {
        case .istanbul: return "building.2.fill"
        case .ankara: return "star.circle.fill"
        case .izmir: return "water.waves"
        case .bursa: return "leaf.fill"
        case .antalya: return "sun.max.fill"
        case .adana: return "location.circle.fill"
        }
    }
    
    var locationName: String {
        return displayName
    }
}

#Preview {
    LocationFilterView(location: .constant(nil))
}