import SwiftUI
import Combine

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateEventViewModel()
    @State private var showingImagePicker = false
    @State private var showingGalleryPicker = false
    @State private var isLoading = false
    
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
                        // MARK: - Event Image
                        eventImageSection
                        
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
                        
                        // MARK: - Gallery
                        gallerySection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Yeni Event")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
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
    
    // MARK: - Event Image Section
    private var eventImageSection: some View {
        FormSectionCard(title: "Event Görseli", isRequired: true, icon: "photo") {
            Button(action: {
                showingImagePicker = true
            }) {
                if viewModel.imageURL.isEmpty {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "photo.badge.plus")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("Fotoğraf Seç")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Event'inizi en iyi şekilde temsil eden görseli seçin")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.green)
                                Text("Görsel Seçildi")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                        )
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .sheet(isPresented: $showingImagePicker) {
                Text("Image Picker - TODO")
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        FormSectionCard(title: "Temel Bilgiler", icon: "info.circle") {
            VStack(spacing: 20) {
                ModernTextField("Event Başlığı", text: $viewModel.title, isRequired: true)
                
                ModernTextEditor("Açıklama", text: $viewModel.description, isRequired: false, height: 100)
                
                CategorySelector(selectedCategories: $viewModel.selectedCategories)
                
                ModernTextEditor("Ne Beklemeli?", text: $viewModel.whatToExpected, isRequired: false ,height: 80)
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
                
                HStack(spacing: 12) {
                    ModernTextField("Enlem", text: $viewModel.locationLatitude)
                        .keyboardType(.decimalPad)
                    ModernTextField("Boylam", text: $viewModel.locationLongitude)
                        .keyboardType(.decimalPad)
                }
            }
        }
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
                
                ModernTextEditor("Gereksinimler", text: $viewModel.requirements,isRequired: false, height: 80)
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
    
    // MARK: - Gallery Section
    private var gallerySection: some View {
        FormSectionCard(title: "Galeri Görselleri", icon: "photo.stack") {
            Button(action: {
                showingGalleryPicker = true
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .frame(height: 100)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo.stack")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Galeri Fotoğrafları Seç")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text("Maksimum 5 fotoğraf")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [3]))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .sheet(isPresented: $showingGalleryPicker) {
                Text("Gallery Picker - TODO")
            }
            
            if viewModel.hasGalleryImages {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Galeri fotoğrafları seçildi")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func saveEvent() {
        isLoading = true
        
        // TODO: Backend API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            dismiss()
        }
    }
    
    private func isFormValid() -> Bool {
        !viewModel.title.isEmpty &&
        !viewModel.locationName.isEmpty &&
        !viewModel.organizerName.isEmpty &&
        !viewModel.selectedCategories.isEmpty &&
        !viewModel.price.isEmpty
    }
}

// MARK: - Preview
#Preview {
    CreateEventView()
}
