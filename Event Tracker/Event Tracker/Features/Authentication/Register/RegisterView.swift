//
//  RegisterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 9.07.2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @EnvironmentObject var router: Router
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    registrationHeader
                    
                    registrationFormSection
                                    
                    loginPrompt
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Kayıt Ol")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var registrationHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 56))
                .foregroundColor(.green)
                .padding(16)
                .background(Circle().fill(Color.green.opacity(0.1)))
            
            Text("Hesap Oluşturun")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Event Tracker'a katılın ve etkinlikleri keşfedin")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var registrationFormSection: some View {
        FormSectionCard(title: "Hesap Bilgileri", icon: "person.crop.circle.badge.plus") {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("E-posta")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("E-posta adresinizi girin", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.email.isEmpty ? Color.clear : (isValidEmail(viewModel.email) ? Color.green : Color.red), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Şifre")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    SecureField("Güçlü bir şifre oluşturun", text: $viewModel.password)
                        .textContentType(.newPassword)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.password.isEmpty ? Color.clear : (viewModel.password.count >= 6 ? Color.green : Color.red), lineWidth: 1)
                        )
                    
                    if !viewModel.password.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.password.count >= 6 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(viewModel.password.count >= 6 ? .green : .orange)
                                .font(.caption)
                            Text("En az 6 karakter olmalı")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Şifreyi Onayla")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    SecureField("Şifrenizi tekrar girin", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.confirmPassword.isEmpty ? Color.clear : (viewModel.password == viewModel.confirmPassword ? Color.green : Color.red), lineWidth: 1)
                        )
                    
                    if !viewModel.confirmPassword.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.password == viewModel.confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(viewModel.password == viewModel.confirmPassword ? .green : .red)
                                .font(.caption)
                            Text(viewModel.password == viewModel.confirmPassword ? "Şifreler eşleşiyor" : "Şifreler eşleşmiyor")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                if let error = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.footnote)
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
                
                termsAndConditions
                
                Button {
                    Task {
                        await viewModel.register()
                        if viewModel.isRegistered {
                            router.popToRoot()
                        }
                    }
                } label: {
                    ZStack {
                        Text(viewModel.isLoading ? "Hesap oluşturuluyor..." : "Hesap Oluştur")
                            .fontWeight(.semibold)
                            .opacity(viewModel.isLoading ? 0 : 1)
                        if viewModel.isLoading { 
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || !isFormValid())
            }
        }
    }
    
    private var termsAndConditions: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .font(.footnote)
                Text("Hesap oluşturarak")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Button("Kullanım Şartları") {
                    // TODO: Show Terms of Service
                }
                .font(.footnote)
                .foregroundStyle(.blue)
                
                Text("ve")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Button("Gizlilik Politikası") {
                    // TODO: Show Privacy Policy  
                }
                .font(.footnote)
                .foregroundStyle(.blue)
                
                Text("kabul etmiş olursunuz.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var loginPrompt: some View {
        HStack {
            Text("Zaten hesabınız var mı?")
                .font(.footnote)
                .foregroundColor(.secondary)
            Button("Giriş Yap") {
                router.pop()
            }
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundStyle(.blue)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isFormValid() -> Bool {
        return !viewModel.email.isEmpty &&
               !viewModel.password.isEmpty &&
               !viewModel.confirmPassword.isEmpty &&
               isValidEmail(viewModel.email) &&
               viewModel.password.count >= 6 &&
               viewModel.password == viewModel.confirmPassword
    }
}

#Preview {
    RegisterView().environmentObject(Router())
}
