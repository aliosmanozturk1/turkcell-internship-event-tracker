//
//  ParticipantsFilterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI

struct ParticipantsFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ParticipantsFilterViewModel
    @Binding var minParticipants: Int?
    @Binding var maxParticipants: Int?
    
    init(minParticipants: Binding<Int?>, maxParticipants: Binding<Int?>) {
        self._minParticipants = minParticipants
        self._maxParticipants = maxParticipants
        self._viewModel = StateObject(wrappedValue: ParticipantsFilterViewModel(
            minParticipants: minParticipants.wrappedValue,
            maxParticipants: maxParticipants.wrappedValue
        ))
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
                        ParticipantsPresetsSection(viewModel: viewModel)
                        
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
                                text: $viewModel.minParticipantsText,
                                placeholder: "0",
                                viewModel: viewModel,
                                isMaxField: false
                            )
                            
                            // Max Participants
                            ParticipantsInputField(
                                title: "Maksimum Katılımcı Sayısı",
                                text: $viewModel.maxParticipantsText,
                                placeholder: "Sınır yok",
                                viewModel: viewModel,
                                isMaxField: true
                            )
                            
                            // Validation message
                            if let min = viewModel.tempMinParticipants, let max = viewModel.tempMaxParticipants, min > max {
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
                        if viewModel.tempMinParticipants != nil || viewModel.tempMaxParticipants != nil {
                            Button(action: {
                                viewModel.clearFilter()
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
                        viewModel.applyChanges()
                        minParticipants = viewModel.minParticipants
                        maxParticipants = viewModel.maxParticipants
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .disabled(!viewModel.hasChanges || !viewModel.isValidRange)
                }
            }
        }
    }
}

struct ParticipantsPresetsSection: View {
    @ObservedObject var viewModel: ParticipantsFilterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı Seçenekler")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(ParticipantsPreset.allCases, id: \.self) { preset in
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

struct ParticipantsInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @ObservedObject var viewModel: ParticipantsFilterViewModel
    let isMaxField: Bool
    
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
                    .onChange(of: text) { _, newValue in
                        let filteredValue = String(newValue.filter { $0.isNumber })
                        if text != filteredValue {
                            text = filteredValue
                        }
                        
                        if isMaxField {
                            viewModel.updateMaxParticipants(from: filteredValue)
                        } else {
                            viewModel.updateMinParticipants(from: filteredValue)
                        }
                    }
                    .onChange(of: isFocused) { _, editing in
                        if editing {
                            viewModel.clearPresetSelection()
                        }
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        if isMaxField {
                            viewModel.tempMaxParticipants = nil
                        } else {
                            viewModel.tempMinParticipants = nil
                        }
                        viewModel.clearPresetSelection()
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


#Preview {
    ParticipantsFilterView(minParticipants: .constant(nil), maxParticipants: .constant(nil))
}
