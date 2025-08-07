//
//  EventDetailViewModel.swift
//  Event Tracker
//
//  Created by Claude Code on 7.08.2025.
//

import SwiftUI
import Combine
import EventKit

@MainActor
final class EventDetailViewModel: ObservableObject {
    @Published var event: CreateEventModel
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCalendarAlert = false
    @Published var calendarAlertMessage = ""
    
    private let eventStore = EKEventStore()
    
    init(event: CreateEventModel) {
        self.event = event
    }
    
    // MARK: - Date Formatting
    func formatDate(_ date: Date, includeTime: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        
        if includeTime {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .medium
        }
        
        return formatter.string(from: date)
    }
    
    // MARK: - Language Display
    func languageDisplayName(_ languageCode: String) -> String {
        switch languageCode {
        case "tr":
            return "Türkçe"
        case "en":
            return "English"
        case "ar":
            return "العربية"
        default:
            return languageCode
        }
    }
    
    // MARK: - Status Color
    var statusColor: Color {
        switch event.status {
        case .active:
            return .green
        case .cancelled:
            return .red
        case .completed:
            return .blue
        case .draft:
            return .orange
        }
    }
    
    // MARK: - Share Functionality
    var shareContent: String {
        """
        🎉 \(event.title)
        
        📅 \(formatDate(event.startDate, includeTime: true))
        📍 \(event.location.name)
        
        \(event.description)
        
        Event Tracker uygulaması ile paylaşıldı
        """
    }
    
    // MARK: - Calendar Integration
    func addToCalendar() {
        Task {
            await requestCalendarAccess()
        }
    }
    
    private func requestCalendarAccess() async {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                if granted {
                    await createCalendarEvent()
                } else {
                    showCalendarAlert(message: "Takvim erişim izni reddedildi")
                }
            } catch {
                showCalendarAlert(message: "Takvim erişim izni alınamadı: \(error.localizedDescription)")
            }
        case .authorized:
            await createCalendarEvent()
        case .fullAccess:
            await createCalendarEvent()
        case .writeOnly:
            await createCalendarEvent()
        case .denied, .restricted:
            showCalendarAlert(message: "Takvim erişimi engellendi. Lütfen Ayarlar > Gizlilik & Güvenlik > Takvimler'den izin verin.")
        @unknown default:
            showCalendarAlert(message: "Bilinmeyen yetkilendirme durumu")
        }
    }
    
    private func createCalendarEvent() async {
        let calendarEvent = EKEvent(eventStore: eventStore)
        calendarEvent.title = event.title
        calendarEvent.notes = event.description
        calendarEvent.startDate = event.startDate
        calendarEvent.endDate = event.endDate
        calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        // Add location if available
        if !event.location.fullAddress.isEmpty {
            calendarEvent.location = event.location.fullAddress
        } else {
            calendarEvent.location = event.location.name
        }
        
        // Add alarm 1 hour before
        let alarm = EKAlarm(relativeOffset: -3600) // 1 hour before
        calendarEvent.addAlarm(alarm)
        
        do {
            try eventStore.save(calendarEvent, span: .thisEvent)
            showCalendarAlert(message: "Event takviminize başarıyla eklendi!")
        } catch {
            showCalendarAlert(message: "Event takvime eklenirken hata oluştu: \(error.localizedDescription)")
        }
    }
    
    private func showCalendarAlert(message: String) {
        calendarAlertMessage = message
        showingCalendarAlert = true
    }
    
    // MARK: - External Links
    func visitWebsite() {
        guard !event.organizer.website.isEmpty,
              let url = URL(string: event.organizer.website) else { return }
        UIApplication.shared.open(url)
    }
    
    func sendEmail(to email: String) {
        guard !email.isEmpty else { return }
        
        let subject = "Event Hakkında: \(event.title)"
        let body = """
        Merhaba,
        
        \(event.title) adlı event hakkında bilgi almak istiyorum.
        
        Event Detayları:
        📅 \(formatDate(event.startDate, includeTime: true))
        📍 \(event.location.name)
        
        Teşekkürler,
        """
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let mailtoURL = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(mailtoURL)
        }
    }
    
    func callPhone(_ phone: String) {
        guard !phone.isEmpty,
              let url = URL(string: "tel:\(phone)") else { return }
        UIApplication.shared.open(url)
    }
    
    func openMaps() {
        guard let lat = Double(event.location.latitude),
              let lon = Double(event.location.longitude),
              !event.location.latitude.isEmpty,
              !event.location.longitude.isEmpty else { return }
        
        let encodedName = event.location.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "http://maps.apple.com/?ll=\(lat),\(lon)&q=\(encodedName)")!
        UIApplication.shared.open(url)
    }
    
    // MARK: - Event Actions
    func refreshEventData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // If we have event ID, we could fetch updated data from Firebase
            // For now, we'll keep the current event data
            // let updatedEvent = try await EventService.shared.fetchEvent(id: event.id)
            // self.event = updatedEvent
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
}