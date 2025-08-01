import SwiftUI
import Combine
import PhotosUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateEventViewModel()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var editMode: EditMode = .inactive
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
                        // MARK: - Event Photos
                        photosSection
                        
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
    
    // MARK: - Photos Section
    private var photosSection: some View {
        FormSectionCard(title: "Event Fotoğrafları", isRequired: true, icon: "photo.on.rectangle.angled") {
            VStack(spacing: 12) {
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.05))
                        .frame(height: 100)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text(selectedImages.isEmpty ? "Fotoğrafları Seç" : "Fotoğrafları Düzenle")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .onChange(of: selectedItems) { newItems in
                    Task {
                        selectedImages.removeAll()
                        viewModel.galleryImageURLs.removeAll()
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImages.append(uiImage)
                                // Placeholder URL generation
                                viewModel.galleryImageURLs.append(UUID().uuidString)
                            }
                        }
                        viewModel.coverImageIndex = 0
                    }
                }

                if !selectedImages.isEmpty {
                    EditButton()
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    List {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            HStack {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(alignment: .topTrailing) {
                                        if index == viewModel.coverImageIndex {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .padding(4)
                                        }
                                    }
                                Text(index == viewModel.coverImageIndex ? "Kapak" : "Fotoğraf \(index + 1)")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.coverImageIndex = index
                            }
                        }
                        .onMove { indices, newOffset in
                            selectedImages.move(fromOffsets: indices, toOffset: newOffset)
                            viewModel.galleryImageURLs.move(fromOffsets: indices, toOffset: newOffset)
                            if let first = indices.first {
                                if first == viewModel.coverImageIndex {
                                    viewModel.coverImageIndex = newOffset > first ? newOffset - 1 : newOffset
                                } else if first < viewModel.coverImageIndex && newOffset > viewModel.coverImageIndex {
                                    viewModel.coverImageIndex -= 1
                                } else if first > viewModel.coverImageIndex && newOffset <= viewModel.coverImageIndex {
                                    viewModel.coverImageIndex += 1
                                }
                            }
                        }
                    }
                    .environment(\.editMode, $editMode)
                    .frame(height: min(300, CGFloat(selectedImages.count) * 70))
                }
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
    
    
    // MARK: - Helper Functions
    private func saveEvent() {
        isLoading = true
        Task {
            await viewModel.createEvent()
            isLoading = false
            if viewModel.isEventCreated {
                dismiss()
            }
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
