import SwiftUI
import Combine
import PhotosUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateEventViewModel()
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var coverIndex: Int = 0
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
                        // MARK: - Görseller
                        imagesSection
                        
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

    // MARK: - Images Section
    private var imagesSection: some View {
        FormSectionCard(title: "Görseller", isRequired: true, icon: "photo.on.rectangle") {
            PhotosPicker(selection: $photoItems, maxSelectionCount: 5, matching: .images) {
                if selectedImages.isEmpty {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                        .frame(height: 100)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("Fotoğraf Seç")
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
                } else {
                    HStack {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(index == coverIndex ? Color.blue : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    coverIndex = index
                                }
                        }
                    }
                }
            }
            .onChange(of: photoItems) { newItems in
                Task {
                    var tempImages: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            tempImages.append(uiImage)
                        }
                    }
                    selectedImages = tempImages
                    viewModel.imageUrls = Array(repeating: "", count: tempImages.count)
                }
            }

            if !selectedImages.isEmpty {
                List {
                    ForEach(selectedImages.indices, id: \.self) { index in
                        HStack {
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()

                            Text(index == coverIndex ? "Kapak" : "")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            coverIndex = index
                        }
                    }
                    .onMove { indices, newOffset in
                        selectedImages.move(fromOffsets: indices, toOffset: newOffset)
                        photoItems.move(fromOffsets: indices, toOffset: newOffset)
                        viewModel.imageUrls.move(fromOffsets: indices, toOffset: newOffset)
                        if let currentCover = indices.first(where: { $0 == coverIndex }) {
                            coverIndex = newOffset > currentCover ? newOffset - 1 : newOffset
                        } else if let first = indices.first {
                            if first < coverIndex && newOffset > coverIndex { coverIndex -= 1 }
                            else if first > coverIndex && newOffset <= coverIndex { coverIndex += 1 }
                        }
                    }
                }
                .editActions(.move)
                .frame(maxHeight: 250)
            }
        }
    }
    
    
    // MARK: - Helper Functions
    private func saveEvent() {
        isLoading = true
        Task {
            if coverIndex < viewModel.imageUrls.count {
                viewModel.imageUrls.swapAt(0, coverIndex)
            }
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
