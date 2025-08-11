import Combine
import SwiftUI
import CoreLocation

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router
    @StateObject private var viewModel = CreateEventViewModel()
    @State private var isLoading = false
    @State private var showLocationPicker = false
    @State private var selectedAddress: String = ""
    
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
                        // MARK: - Photos
                        photoSection
                        
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
            .navigationTitle("Yeni Event")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveEvent()
                    } label: {
                        HStack(spacing: 4) {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Text("Kaydet")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(isFormValid() ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .disabled(!isFormValid() || isLoading)
                }
            }
        }
    }
    
    // MARK: - Photo Section

    private var photoSection: some View {
        FormSectionCard(title: "Event Fotoğrafları", isRequired: true, icon: "photo.on.rectangle") {
            PhotoUploadView(images: $viewModel.selectedImages)
        }
    }
    
    // MARK: - Basic Info Section

    private var basicInfoSection: some View {
        FormSectionCard(title: "Temel Bilgiler", icon: "info.circle") {
            VStack(spacing: 20) {
                ModernTextField("Event Başlığı", text: $viewModel.title, isRequired: true)
                
                ModernTextEditor("Açıklama", text: $viewModel.description, isRequired: false, height: 100)
                
                CategorySelector(selectedCategories: $viewModel.selectedCategories)
                
                ModernTextEditor("Ne Beklemeli?", text: $viewModel.whatToExpected, isRequired: false, height: 80)
            }
        }
    }
    
    // MARK: - Date & Time Section

    private var dateTimeSection: some View {
        FormSectionCard(title: "Tarih ve Saat", icon: "calendar") {
            VStack(spacing: 20) {
                ModernDatePicker("Başlangıç Tarihi", date: $viewModel.startDate, isRequired: true)
                
                ModernDatePicker("Bitiş Tarihi", date: $viewModel.endDate)
                
                ModernDatePicker("Kayıt Son Tarihi", date: $viewModel.registrationDeadline)
            }
        }
    }
    
    // MARK: - Location Section

    private var locationSection: some View {
        FormSectionCard(title: "Konum Bilgileri", icon: "location") {
            VStack(spacing: 20) {
                ModernTextField("Mekan Adı", text: $viewModel.locationName, isRequired: true)
                ModernTextField("Adres 1", text: $viewModel.locationAddress1)
                ModernTextField("Adres 2", text: $viewModel.locationAddress2)
                
                HStack(spacing: 12) {
                    ModernTextField("Şehir", text: $viewModel.locationCity)
                    ModernTextField("İlçe", text: $viewModel.locationDistrict)
                }
                
                Button {
                    showLocationPicker = true
                } label: {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        if viewModel.locationLatitude.isEmpty || viewModel.locationLongitude.isEmpty {
                            Text("Haritadan Konum Seç")
                                .foregroundColor(.blue)
                        } else {
                            VStack(alignment: .leading) {
                                Text("Seçilen Konum")
                                Text(selectedAddress.isEmpty ? "\(viewModel.locationLatitude), \(viewModel.locationLongitude)" : selectedAddress)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView(
                latitude: $viewModel.locationLatitude,
                longitude: $viewModel.locationLongitude
            )
        }
        .onChange(of: viewModel.locationLatitude) { _ in reverseGeocodeSelectedLocation() }
        .onChange(of: viewModel.locationLongitude) { _ in reverseGeocodeSelectedLocation() }
        .onAppear { reverseGeocodeSelectedLocation() }
    }
    
    // MARK: - Participants Section

    private var participantsSection: some View {
        FormSectionCard(title: "Katılımcı Bilgileri", icon: "person.3") {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ModernTextField("Max Katılımcı", text: $viewModel.maxParticipants)
                        .keyboardType(.numberPad)
                    ModernTextField("Mevcut Katılımcı", text: $viewModel.currentParticipants)
                        .keyboardType(.numberPad)
                }
                
                ModernToggle(title: "Kalan Kontenjan Gösterilsin", isOn: $viewModel.showRemaining)
            }
        }
    }
    
    // MARK: - Requirements Section

    private var requirementsSection: some View {
        FormSectionCard(title: "Yaş ve Gereksinimler", icon: "person.badge.shield.checkmark") {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ModernTextField("Min Yaş", text: $viewModel.minAge)
                        .keyboardType(.numberPad)
                    ModernTextField("Max Yaş", text: $viewModel.maxAge)
                        .keyboardType(.numberPad)
                }
                
                ModernPicker("Dil", selection: $viewModel.language, options: [
                    ("tr", "Türkçe"),
                    ("en", "English"),
                    ("ar", "العربية")
                ])
                
                ModernTextEditor("Gereksinimler", text: $viewModel.requirements, isRequired: false, height: 80)
            }
        }
    }
    
    // MARK: - Organizer Section

    private var organizerSection: some View {
        FormSectionCard(title: "Organizatör Bilgileri", icon: "person.crop.circle.badge.checkmark") {
            VStack(spacing: 20) {
                ModernTextField("Organizatör Adı", text: $viewModel.organizerName, isRequired: true)
                ModernTextField("Email", text: $viewModel.organizerEmail)
                    .keyboardType(.emailAddress)
                ModernTextField("Telefon", text: $viewModel.organizerPhone)
                    .keyboardType(.phonePad)
                ModernTextField("Website", text: $viewModel.organizerWebsite)
                    .keyboardType(.URL)
            }
        }
    }
    
    // MARK: - Pricing Section

    private var pricingSection: some View {
        FormSectionCard(title: "Fiyatlandırma", icon: "creditcard") {
            HStack(spacing: 12) {
                ModernTextField("Fiyat", text: $viewModel.price, isRequired: true)
                    .keyboardType(.decimalPad)
                
                ModernPicker("Para Birimi", selection: $viewModel.currency, options: [
                    ("TL", "TL"),
                    ("USD", "USD"),
                    ("EUR", "EUR")
                ])
                .frame(maxWidth: 120)
            }
        }
    }
    
    // MARK: - Additional Info Section

    private var additionalInfoSection: some View {
        FormSectionCard(title: "Ek Bilgiler", icon: "ellipsis.circle") {
            VStack(spacing: 20) {
                ModernPicker("Durum", selection: $viewModel.status, options: [
                    ("active", "Aktif"),
                    ("draft", "Taslak"),
                    ("cancelled", "İptal")
                ])
                
                ModernTextField("Sosyal Medya Linkleri", text: $viewModel.socialLinks)
                ModernTextField("İletişim Bilgileri", text: $viewModel.contactInfo)
            }
        }
    }
    
    // MARK: - Helper Functions

    private func saveEvent() {
        isLoading = true
        Task {
            await viewModel.createEvent()
            isLoading = false
            if viewModel.isEventCreated, let createdEvent = viewModel.createdEvent {
                viewModel.clearForm()
                router.push(.eventDetail(createdEvent))
            }
        }
    }
    
    private func isFormValid() -> Bool {
        !viewModel.title.isEmpty &&
            !viewModel.locationName.isEmpty &&
            !viewModel.organizerName.isEmpty &&
            !viewModel.selectedCategories.isEmpty &&
            !viewModel.selectedImages.isEmpty &&
            !viewModel.price.isEmpty
    }
}

// MARK: - Reverse Geocoding
private extension CreateEventView {
    func reverseGeocodeSelectedLocation() {
        guard
            let lat = Double(viewModel.locationLatitude),
            let lon = Double(viewModel.locationLongitude)
        else { return }

        let location = CLLocation(latitude: lat, longitude: lon)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            guard let placemark = placemarks?.first else { return }
            selectedAddress = formatAddress(from: placemark)
        }
    }

    func formatAddress(from placemark: CLPlacemark) -> String {
        var parts: [String] = []
        if let name = placemark.name { parts.append(name) }
        if let thoroughfare = placemark.thoroughfare { parts.append(thoroughfare) }
        if let subLocality = placemark.subLocality { parts.append(subLocality) }
        if let locality = placemark.locality { parts.append(locality) }
        if let administrativeArea = placemark.administrativeArea { parts.append(administrativeArea) }
        if let postalCode = placemark.postalCode { parts.append(postalCode) }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Preview

#Preview {
    CreateEventView()
}
