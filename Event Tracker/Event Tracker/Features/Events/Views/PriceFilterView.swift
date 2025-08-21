//
//  PriceFilterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI

struct PriceFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var minPrice: Double?
    @Binding var maxPrice: Double?
    @StateObject private var viewModel: PriceFilterViewModel
    
    init(minPrice: Binding<Double?>, maxPrice: Binding<Double?>) {
        self._minPrice = minPrice
        self._maxPrice = maxPrice
        self._viewModel = StateObject(wrappedValue: PriceFilterViewModel(minPrice: minPrice.wrappedValue, maxPrice: maxPrice.wrappedValue))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Fiyat Aralığı")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Etkinlikleri fiyat aralığına göre filtreleyin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick presets
                        PricePresetsSection(viewModel: viewModel)
                        
                        Divider()
                        
                        // Custom price range
                        VStack(spacing: 20) {
                            Text("Özel Fiyat Aralığı")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Min Price
                            PriceInputField(
                                title: "Minimum Fiyat",
                                text: $viewModel.minPriceText,
                                placeholder: "₺0",
                                isMinPrice: true,
                                viewModel: viewModel
                            )
                            
                            // Max Price
                            PriceInputField(
                                title: "Maksimum Fiyat",
                                text: $viewModel.maxPriceText,
                                placeholder: "Sınır yok",
                                isMinPrice: false,
                                viewModel: viewModel
                            )
                            
                            // Validation message
                            if let min = viewModel.tempMinPrice, let max = viewModel.tempMaxPrice, min > max {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    
                                    Text("Minimum fiyat maksimumdan büyük olamaz")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Clear all button
                        if viewModel.tempMinPrice != nil || viewModel.tempMaxPrice != nil {
                            Button(action: {
                                viewModel.clearPriceFilter()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.subheadline)
                                    
                                    Text("Fiyat Filtresini Temizle")
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
            .navigationTitle("Fiyat Filtresi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        minPrice = viewModel.tempMinPrice
                        maxPrice = viewModel.tempMaxPrice
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .disabled(!viewModel.hasChanges || !viewModel.isValidRange)
                }
            }
        }
    }
}

struct PricePresetsSection: View {
    @ObservedObject var viewModel: PriceFilterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı Seçenekler")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(PricePreset.allCases, id: \.self) { preset in
                    Button(action: {
                        viewModel.selectPreset(preset)
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

struct PriceInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let isMinPrice: Bool
    @ObservedObject var viewModel: PriceFilterViewModel
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "turkishlirasign.circle")
                    .foregroundColor(.blue)
                
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        if isMinPrice {
                            viewModel.updateMinPrice(from: newValue)
                        } else {
                            viewModel.updateMaxPrice(from: newValue)
                        }
                    }
                    .onChange(of: isFocused) { _, editing in
                        if editing {
                            if isMinPrice {
                                viewModel.onMinPriceFocused()
                            } else {
                                viewModel.onMaxPriceFocused()
                            }
                        }
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        if isMinPrice {
                            viewModel.clearMinPrice()
                        } else {
                            viewModel.clearMaxPrice()
                        }
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

enum PricePreset: String, CaseIterable {
    case free = "free"
    case under50 = "under50"
    case under100 = "under100"
    case under250 = "under250"
    case under500 = "under500"
    case over500 = "over500"
    
    var displayName: String {
        switch self {
        case .free: return "Ücretsiz"
        case .under50: return "₺50 Altı"
        case .under100: return "₺100 Altı"
        case .under250: return "₺250 Altı"
        case .under500: return "₺500 Altı"
        case .over500: return "₺500 Üzeri"
        }
    }
    
    var description: String {
        switch self {
        case .free: return "Sadece ücretsiz etkinlikler"
        case .under50: return "₺0 - ₺50 arası"
        case .under100: return "₺0 - ₺100 arası"
        case .under250: return "₺0 - ₺250 arası"
        case .under500: return "₺0 - ₺500 arası"
        case .over500: return "₺500 ve üzeri"
        }
    }
    
    var icon: String {
        switch self {
        case .free: return "gift.fill"
        case .under50: return "turkishlirasign.circle"
        case .under100: return "turkishlirasign.square"
        case .under250: return "creditcard.fill"
        case .under500: return "banknote.fill"
        case .over500: return "diamond.fill"
        }
    }
    
    var priceRange: (min: Double?, max: Double?) {
        switch self {
        case .free: return (0, 0)
        case .under50: return (nil, 50)
        case .under100: return (nil, 100)
        case .under250: return (nil, 250)
        case .under500: return (nil, 500)
        case .over500: return (500, nil)
        }
    }
}

#Preview {
    PriceFilterView(minPrice: .constant(nil), maxPrice: .constant(nil))
}
