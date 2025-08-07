import SwiftUI

struct EventDetailView: View {
    let event: CreateEventModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 32) {
                        // MARK: - Photo Gallery
                        photoGallerySection
                        
                        // MARK: - Basic Info
                        basicInfoSection
                        
                        // MARK: - Date & Time
                        dateTimeSection
                        
                        // MARK: - Location
                        locationSection
                        
                        // MARK: - Participants
                        participantsSection
                        
                        // MARK: - Age & Requirements
                        requirementsSection
                        
                        // MARK: - Organizer Info
                        organizerSection
                        
                        // MARK: - Pricing
                        pricingSection
                        
                        // MARK: - Additional Info
                        additionalInfoSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle(event.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: shareEvent) {
                            Label("Paylaş", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: addToCalendar) {
                            Label("Takvime Ekle", systemImage: "calendar.badge.plus")
                        }
                        
                        if !event.organizer.website.isEmpty {
                            Button(action: visitWebsite) {
                                Label("Website", systemImage: "globe")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    // MARK: - Photo Gallery Section
    private var photoGallerySection: some View {
        FormSectionCard(title: "Event Fotoğrafları", icon: "photo.on.rectangle") {
            if !event.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(event.images, id: \.id) { image in
                            AsyncImage(url: URL(string: image.url)) { img in
                                img
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 150)
                                    .clipped()
                                    .cornerRadius(12)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 200, height: 150)
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 150)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.title2)
                            Text("Fotoğraf bulunmuyor")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    )
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        FormSectionCard(title: "Event Bilgileri", icon: "info.circle") {
            VStack(alignment: .leading, spacing: 16) {
                if !event.description.isEmpty {
                    DetailRow(title: "Açıklama", value: event.description, isMultiline: true)
                }
                
                if !event.categories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kategoriler")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(event.categories, id: \.self) { category in
                                    Text(category)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                if !event.whatToExpected.isEmpty {
                    DetailRow(title: "Ne Beklemeli?", value: event.whatToExpected, isMultiline: true)
                }
                
                // Event Status
                HStack {
                    Text("Durum")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(event.status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.1))
                        )
                        .foregroundColor(statusColor)
                }
            }
        }
    }
    
    // MARK: - Date & Time Section
    private var dateTimeSection: some View {
        FormSectionCard(title: "Tarih ve Saat", icon: "calendar") {
            VStack(spacing: 16) {
                DetailRow(title: "Başlangıç", value: formatDate(event.startDate, includeTime: true))
                
                if event.endDate > event.startDate {
                    DetailRow(title: "Bitiş", value: formatDate(event.endDate, includeTime: true))
                }
                
                if event.registrationDeadline < event.startDate {
                    DetailRow(title: "Kayıt Son Tarihi", value: formatDate(event.registrationDeadline, includeTime: true))
                }
            }
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        FormSectionCard(title: "Konum Bilgileri", icon: "location") {
            VStack(spacing: 16) {
                DetailRow(title: "Mekan", value: event.location.name)
                
                if !event.location.fullAddress.isEmpty {
                    DetailRow(title: "Adres", value: event.location.fullAddress, isMultiline: true)
                }
                
                if !event.location.latitude.isEmpty && !event.location.longitude.isEmpty {
                    HStack {
                        Text("Koordinatlar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button(action: openMaps) {
                            HStack(spacing: 4) {
                                Image(systemName: "map")
                                    .font(.caption)
                                Text("Haritada Aç")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Participants Section
    private var participantsSection: some View {
        FormSectionCard(title: "Katılımcı Bilgileri", icon: "person.3") {
            VStack(spacing: 16) {
                if event.participants.maxParticipants > 0 {
                    HStack {
                        Text("Kapasite")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(event.participants.currentParticipants)/\(event.participants.maxParticipants)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    // Progress bar
                    ProgressView(value: Double(event.participants.currentParticipants), total: Double(event.participants.maxParticipants))
                        .progressViewStyle(LinearProgressViewStyle(tint: event.participants.isFull ? .red : .blue))
                    
                    if event.participants.showRemaining && !event.participants.isFull {
                        Text("\(event.participants.remainingSpots) kişilik yer kaldı")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if event.participants.isFull {
                        Text("Event dolu")
                            .font(.caption)
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                    }
                } else {
                    DetailRow(title: "Katılımcı Sayısı", value: "Sınırsız")
                }
            }
        }
    }
    
    // MARK: - Requirements Section
    private var requirementsSection: some View {
        FormSectionCard(title: "Yaş ve Gereksinimler", icon: "person.badge.shield.checkmark") {
            VStack(spacing: 16) {
                DetailRow(title: "Yaş Sınırı", value: event.ageRestriction.ageRangeText)
                
                DetailRow(title: "Dil", value: languageDisplayName(event.language))
                
                if !event.requirements.isEmpty {
                    DetailRow(title: "Gereksinimler", value: event.requirements, isMultiline: true)
                }
            }
        }
    }
    
    // MARK: - Organizer Section
    private var organizerSection: some View {
        FormSectionCard(title: "Organizatör Bilgileri", icon: "person.crop.circle.badge.checkmark") {
            VStack(spacing: 16) {
                DetailRow(title: "Organizatör", value: event.organizer.name)
                
                if !event.organizer.email.isEmpty {
                    HStack {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button(action: { sendEmail(to: event.organizer.email) }) {
                            Text(event.organizer.email)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                if !event.organizer.phone.isEmpty {
                    HStack {
                        Text("Telefon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button(action: { callPhone(event.organizer.phone) }) {
                            Text(event.organizer.phone)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                if !event.organizer.website.isEmpty {
                    HStack {
                        Text("Website")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button(action: visitWebsite) {
                            Text(event.organizer.website)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        FormSectionCard(title: "Fiyatlandırma", icon: "creditcard") {
            HStack {
                Text("Fiyat")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(event.pricing.formattedPrice)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(event.pricing.isFree ? .green : .primary)
            }
        }
    }
    
    // MARK: - Additional Info Section
    private var additionalInfoSection: some View {
        FormSectionCard(title: "Ek Bilgiler", icon: "ellipsis.circle") {
            VStack(spacing: 16) {
                if !event.socialLinks.isEmpty {
                    DetailRow(title: "Sosyal Medya", value: event.socialLinks, isMultiline: true)
                }
                
                if !event.contactInfo.isEmpty {
                    DetailRow(title: "İletişim", value: event.contactInfo, isMultiline: true)
                }
                
                DetailRow(title: "Oluşturulma", value: formatDate(event.createdAt))
                
                if event.updatedAt > event.createdAt {
                    DetailRow(title: "Son Güncelleme", value: formatDate(event.updatedAt))
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private struct DetailRow: View {
        let title: String
        let value: String
        let isMultiline: Bool
        
        init(title: String, value: String, isMultiline: Bool = false) {
            self.title = title
            self.value = value
            self.isMultiline = isMultiline
        }
        
        var body: some View {
            if isMultiline {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Text(value)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                HStack {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(value)
                        .font(.subheadline)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var statusColor: Color {
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
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date, includeTime: Bool = false) -> String {
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
    
    private func languageDisplayName(_ languageCode: String) -> String {
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
    
    private func shareEvent() {
        // TODO: Implement share functionality
        print("Share event: \(event.title)")
    }
    
    private func addToCalendar() {
        // TODO: Implement calendar integration
        print("Add to calendar: \(event.title)")
    }
    
    private func visitWebsite() {
        if let url = URL(string: event.organizer.website) {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail(to email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func callPhone(_ phone: String) {
        if let url = URL(string: "tel:\(phone)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openMaps() {
        if let lat = Double(event.location.latitude),
           let lon = Double(event.location.longitude) {
            let url = URL(string: "http://maps.apple.com/?ll=\(lat),\(lon)&q=\(event.location.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleEvent = CreateEventModel(
        title: "iOS Developer Meetup - SwiftUI ile Modern Uygulama Geliştirme",
        description: "Bu etkinlikte SwiftUI ile modern iOS uygulamaları geliştirme konusunu ele alacağız. Temel konulardan başlayarak ileri seviye tekniklerini öğreneceğiz.",
        categories: ["Teknoloji", "Yazılım", "Networking"],
        whatToExpected: "SwiftUI temel bilgiler, Navigation, State Management, API entegrasyonu konularını öğreneceksiniz.",
        startDate: Date(),
        endDate: Date().addingTimeInterval(7200),
        registrationDeadline: Date().addingTimeInterval(-86400),
        location: EventLocation(
            name: "ITU Teknokent",
            address1: "İTÜ Ayazağa Kampüsü",
            address2: "Teknokent ARI 4 Binası",
            city: "İstanbul",
            district: "Sarıyer",
            latitude: "41.1068",
            longitude: "29.0199"
        ),
        participants: EventParticipants(
            maxParticipants: 50,
            currentParticipants: 23,
            showRemaining: true
        ),
        ageRestriction: AgeRestriction(minAge: 18, maxAge: nil),
        language: "tr",
        requirements: "Laptop getirmeniz önerilir. Temel programlama bilgisi yeterlidir.",
        organizer: EventOrganizer(
            name: "İstanbul iOS Developers",
            email: "info@istanburios.com",
            phone: "+90 555 123 4567",
            website: "https://istanburios.com"
        ),
        pricing: EventPricing(price: 0, currency: "TL"),
        status: .active,
        socialLinks: "@istanburios",
        contactInfo: "Whatsapp grupumuz: https://chat.whatsapp.com/example",
        images: [
            EventImage(url: "https://example.com/event1.jpg", thumbnailUrl: "https://example.com/event1-thumb.jpg"),
            EventImage(url: "https://example.com/event2.jpg", thumbnailUrl: "https://example.com/event2-thumb.jpg")
        ],
        createdBy: "1"
    )
    
    EventDetailView(event: sampleEvent)
}