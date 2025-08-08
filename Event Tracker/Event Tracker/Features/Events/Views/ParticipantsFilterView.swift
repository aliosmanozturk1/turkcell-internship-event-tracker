//
//  ParticipantsFilterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI

struct ParticipantsFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var minParticipants: Int?
    @Binding var maxParticipants: Int?
    
    @State private var tempMinParticipants: Int?
    @State private var tempMaxParticipants: Int?
    @State private var selectedPreset: ParticipantsPreset?
    @State private var minParticipantsText: String = ""
    @State private var maxParticipantsText: String = ""
    
    private let initialMinParticipants: Int?
    private let initialMaxParticipants: Int?
    
    init(minParticipants: Binding<Int?>, maxParticipants: Binding<Int?>) {
        self._minParticipants = minParticipants
        self._maxParticipants = maxParticipants
        self.initialMinParticipants = minParticipants.wrappedValue
        self.initialMaxParticipants = maxParticipants.wrappedValue
        self._tempMinParticipants = State(initialValue: minParticipants.wrappedValue)
        self._tempMaxParticipants = State(initialValue: maxParticipants.wrappedValue)
        self._minParticipantsText = State(initialValue: minParticipants.wrappedValue?.description ?? "")
        self._maxParticipantsText = State(initialValue: maxParticipants.wrappedValue?.description ?? "")
    }
    
    private var hasChanges: Bool {
        tempMinParticipants != initialMinParticipants || tempMaxParticipants != initialMaxParticipants
    }
    
    private var isValidRange: Bool {
        guard let min = tempMinParticipants, let max = tempMaxParticipants else { return true }
        return min <= max
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Katılımcı Sayısı")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Etkinlikleri katılımcı sayısına göre filtreleyin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick presets
                        ParticipantsPresetsSection(
                            selectedPreset: $selectedPreset,
                            tempMinParticipants: $tempMinParticipants,
                            tempMaxParticipants: $tempMaxParticipants,
                            minParticipantsText: $minParticipantsText,
                            maxParticipantsText: $maxParticipantsText
                        )
                        
                        Divider()
                        
                        // Custom participants range
                        VStack(spacing: 20) {
                            Text("Özel Katılımcı Aralığı")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Min Participants
                            ParticipantsInputField(
                                title: "Minimum Katılımcı Sayısı",
                                text: $minParticipantsText,
                                placeholder: "0",
                                value: $tempMinParticipants,
                                selectedPreset: $selectedPreset
                            )
                            
                            // Max Participants
                            ParticipantsInputField(
                                title: "Maksimum Katılımcı Sayısı",
                                text: $maxParticipantsText,
                                placeholder: "Sınır yok",
                                value: $tempMaxParticipants,
                                selectedPreset: $selectedPreset
                            )
                            
                            // Validation message
                            if let min = tempMinParticipants, let max = tempMaxParticipants, min > max {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    
                                    Text("Minimum katılımcı sayısı maksimumdan büyük olamaz")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Info box
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Bilgi")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Bu filtre mevcut katılımcı sayısına göre çalışır. Etkinliğe şu anda kaydolan kişi sayısını baz alır.")
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
                        
                        // Clear all button
                        if tempMinParticipants != nil || tempMaxParticipants != nil {
                            Button(action: {
                                tempMinParticipants = nil
                                tempMaxParticipants = nil
                                minParticipantsText = ""
                                maxParticipantsText = ""
                                selectedPreset = nil
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.subheadline)
                                    
                                    Text("Katılımcı Filtresini Temizle")
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
            .navigationTitle("Katılımcı Filtresi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        minParticipants = tempMinParticipants
                        maxParticipants = tempMaxParticipants
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .disabled(!hasChanges || !isValidRange)
                }
            }
        }
    }
}

struct ParticipantsPresetsSection: View {
    @Binding var selectedPreset: ParticipantsPreset?
    @Binding var tempMinParticipants: Int?
    @Binding var tempMaxParticipants: Int?
    @Binding var minParticipantsText: String
    @Binding var maxParticipantsText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı Seçenekler")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(ParticipantsPreset.allCases, id: \.self) { preset in
                    Button(action: {
                        selectedPreset = preset
                        let range = preset.participantsRange
                        tempMinParticipants = range.min
                        tempMaxParticipants = range.max
                        minParticipantsText = range.min?.description ?? ""
                        maxParticipantsText = range.max?.description ?? ""
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

struct ParticipantsInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @Binding var value: Int?
    @Binding var selectedPreset: ParticipantsPreset?
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "person.2")
                    .foregroundColor(.blue)
                
                TextField(placeholder, text: $text)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .onChange(of: text) { newValue in
                        // Sadece değeri güncelle, preset seçimini dokunma
                        if newValue.isEmpty {
                            value = nil
                        } else if let intValue = Int(newValue), intValue >= 0 {
                            value = intValue
                        } else {
                            // Remove invalid characters
                            text = String(newValue.filter { $0.isNumber })
                        }
                    }
                    .onChange(of: isFocused) { editing in
                        // Kullanıcı yazmaya başladığında preset seçimini temizle
                        if editing {
                            selectedPreset = nil
                        }
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        value = nil
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
    }
}

enum ParticipantsPreset: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case huge = "huge"
    case popular = "popular"
    case exclusive = "exclusive"
    
    var displayName: String {
        switch self {
        case .small: return "Küçük Grup"
        case .medium: return "Orta Grup"
        case .large: return "Büyük Grup"
        case .huge: return "Çok Büyük"
        case .popular: return "Popüler"
        case .exclusive: return "Seçkin"
        }
    }
    
    var description: String {
        switch self {
        case .small: return "1-20 kişi"
        case .medium: return "21-50 kişi"
        case .large: return "51-100 kişi"
        case .huge: return "100+ kişi"
        case .popular: return "50+ katılımcı"
        case .exclusive: return "Maksimum 10 kişi"
        }
    }
    
    var icon: String {
        switch self {
        case .small: return "person.2"
        case .medium: return "person.3"
        case .large: return "person.3.sequence"
        case .huge: return "person.3.sequence.fill"
        case .popular: return "heart.fill"
        case .exclusive: return "star.fill"
        }
    }
    
    var participantsRange: (min: Int?, max: Int?) {
        switch self {
        case .small: return (1, 20)
        case .medium: return (21, 50)
        case .large: return (51, 100)
        case .huge: return (100, nil)
        case .popular: return (50, nil)
        case .exclusive: return (nil, 10)
        }
    }
}

#Preview {
    ParticipantsFilterView(minParticipants: .constant(nil), maxParticipants: .constant(nil))
}