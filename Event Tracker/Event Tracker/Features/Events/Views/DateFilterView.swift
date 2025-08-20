//
//  DateFilterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 7.08.2025.
//

import SwiftUI

struct DateFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    
    @State private var tempStartDate: Date?
    @State private var tempEndDate: Date?
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var selectedPreset: DatePreset?
    
    private let initialStartDate: Date?
    private let initialEndDate: Date?
    
    init(startDate: Binding<Date?>, endDate: Binding<Date?>) {
        self._startDate = startDate
        self._endDate = endDate
        self.initialStartDate = startDate.wrappedValue
        self.initialEndDate = endDate.wrappedValue
        self._tempStartDate = State(initialValue: startDate.wrappedValue)
        self._tempEndDate = State(initialValue: endDate.wrappedValue)
    }
    
    private var hasChanges: Bool {
        tempStartDate != initialStartDate || tempEndDate != initialEndDate
    }
    
    private var isValidRange: Bool {
        guard let start = tempStartDate, let end = tempEndDate else { return true }
        return start <= end
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tarih Aralığı")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Etkinlikleri belirli tarih aralığında filtreleyin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick presets
                        DatePresetsSection(
                            selectedPreset: $selectedPreset,
                            tempStartDate: $tempStartDate,
                            tempEndDate: $tempEndDate
                        )
                        
                        Divider()
                        
                        // Custom date selection
                        VStack(spacing: 20) {
                            Text("Özel Tarih Aralığı")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Start Date
                            DateSelectionCard(
                                title: "Başlangıç Tarihi",
                                date: $tempStartDate,
                                showDatePicker: $showStartDatePicker,
                                placeholder: "Tarih seçin"
                            )
                            
                            // End Date
                            DateSelectionCard(
                                title: "Bitiş Tarihi",
                                date: $tempEndDate,
                                showDatePicker: $showEndDatePicker,
                                placeholder: "Tarih seçin"
                            )
                            
                            // Validation message
                            if let start = tempStartDate, let end = tempEndDate, start > end {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    
                                    Text("Başlangıç tarihi bitiş tarihinden sonra olamaz")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Clear all button
                        if tempStartDate != nil || tempEndDate != nil {
                            Button(action: {
                                tempStartDate = nil
                                tempEndDate = nil
                                selectedPreset = nil
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.subheadline)
                                    
                                    Text("Tarihleri Temizle")
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
            .navigationTitle("Tarih Filtresi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        startDate = tempStartDate
                        endDate = tempEndDate
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .disabled(!hasChanges || !isValidRange)
                }
            }
        }
        .sheet(isPresented: $showStartDatePicker) {
            DatePickerSheet(
                title: "Başlangıç Tarihi",
                selectedDate: Binding(
                    get: { tempStartDate ?? Date() },
                    set: { tempStartDate = $0; selectedPreset = nil }
                )
            )
        }
        .sheet(isPresented: $showEndDatePicker) {
            DatePickerSheet(
                title: "Bitiş Tarihi",
                selectedDate: Binding(
                    get: { tempEndDate ?? Date() },
                    set: { tempEndDate = $0; selectedPreset = nil }
                )
            )
        }
    }
}

struct DatePresetsSection: View {
    @Binding var selectedPreset: DatePreset?
    @Binding var tempStartDate: Date?
    @Binding var tempEndDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı Seçenekler")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(DatePreset.allCases, id: \.self) { preset in
                    Button(action: {
                        selectedPreset = preset
                        let range = preset.dateRange
                        tempStartDate = range.start
                        tempEndDate = range.end
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

struct DateSelectionCard: View {
    let title: String
    @Binding var date: Date?
    @Binding var showDatePicker: Bool
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Button(action: {
                showDatePicker = true
            }) {
                HStack {
                    if let date = date {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            
                            Text(date, style: .date)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.blue)
                            
                            Text(placeholder)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    if date != nil {
                        Button(action: {
                            date = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(date != nil ? Color(.systemGray6) : Color.blue.opacity(0.05))
                        .stroke(date != nil ? Color.clear : Color.blue.opacity(0.3),
                               style: StrokeStyle(lineWidth: 1, dash: date != nil ? [] : [3]))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    title,
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
}

enum DatePreset: String, CaseIterable {
    case today = "today"
    case tomorrow = "tomorrow"
    case thisWeek = "thisWeek"
    case nextWeek = "nextWeek"
    case thisMonth = "thisMonth"
    case nextMonth = "nextMonth"
    
    var displayName: String {
        switch self {
        case .today: return "Bugün"
        case .tomorrow: return "Yarın"
        case .thisWeek: return "Bu Hafta"
        case .nextWeek: return "Gelecek Hafta"
        case .thisMonth: return "Bu Ay"
        case .nextMonth: return "Gelecek Ay"
        }
    }
    
    var description: String {
        switch self {
        case .today: return "Sadece bugünkü etkinlikler"
        case .tomorrow: return "Sadece yarınki etkinlikler"
        case .thisWeek: return "Bu hafta içindeki etkinlikler"
        case .nextWeek: return "Gelecek hafta etkinlikleri"
        case .thisMonth: return "Bu ay içindeki etkinlikler"
        case .nextMonth: return "Gelecek ay etkinlikleri"
        }
    }
    
    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .tomorrow: return "sun.horizon.fill"
        case .thisWeek: return "calendar.badge.clock"
        case .nextWeek: return "calendar.badge.plus"
        case .thisMonth: return "calendar"
        case .nextMonth: return "calendar.circle.fill"
        }
    }
    
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
            
        case .tomorrow:
            let start = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
            
        case .thisWeek:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let end = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            return (start, end)
            
        case .nextWeek:
            let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: now)!
            let start = calendar.dateInterval(of: .weekOfYear, for: nextWeekStart)?.start ?? nextWeekStart
            let end = calendar.dateInterval(of: .weekOfYear, for: nextWeekStart)?.end ?? nextWeekStart
            return (start, end)
            
        case .thisMonth:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let end = calendar.dateInterval(of: .month, for: now)?.end ?? now
            return (start, end)
            
        case .nextMonth:
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: now)!
            let start = calendar.dateInterval(of: .month, for: nextMonthStart)?.start ?? nextMonthStart
            let end = calendar.dateInterval(of: .month, for: nextMonthStart)?.end ?? nextMonthStart
            return (start, end)
        }
    }
}

#Preview {
    DateFilterView(startDate: .constant(nil), endDate: .constant(nil))
}