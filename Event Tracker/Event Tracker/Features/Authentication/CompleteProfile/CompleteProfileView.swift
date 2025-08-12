//
//  CompleteProfileView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.07.2025.
//

import SwiftUI

struct CompleteProfileView: View {
    @StateObject private var viewModel = CompleteProfileViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        header

                        formSection

                        if let error = viewModel.errorMessage, !error.isEmpty {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }

                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Profil Tamamlama")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadExistingProfile() }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 48))
                .foregroundColor(.blue)
                .padding(8)
                .background(Circle().fill(Color.blue.opacity(0.1)))
            Text("Profil bilgilerinizi tamamlayın")
                .font(.headline)
                .foregroundColor(.primary)
            Text("Ad ve soyadınızı ekleyin. Daha sonra dilediğiniz zaman güncelleyebilirsiniz.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    private var formSection: some View {
        FormSectionCard(title: "Profil Bilgileri", isRequired: true, icon: "person.crop.circle") {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Adınız")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Adınız", text: $viewModel.firstName)
                        .textContentType(.givenName)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Soyadınız")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Soyadınız", text: $viewModel.lastName)
                        .textContentType(.familyName)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveProfile()
                if viewModel.isProfileCompleted {
                    await sessionManager.refreshUserProfile()
                }
            }
        } label: {
            ZStack {
                Text(viewModel.isSaving ? "Kaydediliyor..." : "Kaydet")
                    .fontWeight(.semibold)
                    .opacity(viewModel.isSaving ? 0 : 1)
                if viewModel.isSaving { ProgressView() }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isSaving)
    }
}

#Preview {
    CompleteProfileView()
        .environmentObject(SessionManager())
}
