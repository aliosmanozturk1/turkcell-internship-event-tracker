//
//  PriceFilterViewModel.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.08.2025.
//

import Foundation
import Combine

@MainActor
final class PriceFilterViewModel: ObservableObject {
    @Published var tempMinPrice: Double?
    @Published var tempMaxPrice: Double?
    @Published var selectedPreset: PricePreset?
    @Published var minPriceText: String = ""
    @Published var maxPriceText: String = ""
    
    private let initialMinPrice: Double?
    private let initialMaxPrice: Double?
    
    init(minPrice: Double?, maxPrice: Double?) {
        self.initialMinPrice = minPrice
        self.initialMaxPrice = maxPrice
        self.tempMinPrice = minPrice
        self.tempMaxPrice = maxPrice
        self.minPriceText = minPrice?.formatted() ?? ""
        self.maxPriceText = maxPrice?.formatted() ?? ""
    }
    
    var hasChanges: Bool {
        tempMinPrice != initialMinPrice || tempMaxPrice != initialMaxPrice
    }
    
    var isValidRange: Bool {
        guard let min = tempMinPrice, let max = tempMaxPrice else { return true }
        return min <= max
    }
    
    func selectPreset(_ preset: PricePreset) {
        selectedPreset = preset
        let range = preset.priceRange
        tempMinPrice = range.min
        tempMaxPrice = range.max
        minPriceText = range.min?.formatted() ?? ""
        maxPriceText = range.max?.formatted() ?? ""
    }
    
    func updateMinPrice(from text: String) {
        if text.isEmpty {
            tempMinPrice = nil
        } else if let doubleValue = Double(text), doubleValue >= 0 {
            tempMinPrice = doubleValue
        }
        selectedPreset = nil
    }
    
    func updateMaxPrice(from text: String) {
        if text.isEmpty {
            tempMaxPrice = nil
        } else if let doubleValue = Double(text), doubleValue >= 0 {
            tempMaxPrice = doubleValue
        }
        selectedPreset = nil
    }
    
    func clearPriceFilter() {
        tempMinPrice = nil
        tempMaxPrice = nil
        minPriceText = ""
        maxPriceText = ""
        selectedPreset = nil
    }
    
    func clearMinPrice() {
        minPriceText = ""
        tempMinPrice = nil
        selectedPreset = nil
    }
    
    func clearMaxPrice() {
        maxPriceText = ""
        tempMaxPrice = nil
        selectedPreset = nil
    }
    
    func onMinPriceFocused() {
        selectedPreset = nil
    }
    
    func onMaxPriceFocused() {
        selectedPreset = nil
    }
}