//
//  LoginView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 9.07.2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
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
                    welcomeHeader
                    
                    loginFormSection
                    
                    socialLoginSection
                    
                    signUpPrompt
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }
        }
        .navigationTitle("Giriş Yap")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: 16) {
            Text("Hoşgeldiniz!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Event Tracker hesabınıza giriş yapın")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            FormSectionCard(title: "Giriş Bilgileri", icon: "envelope.circle") {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("E-posta")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("E-posta adresinizi girin", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Şifre")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        SecureField("Şifrenizi girin", text: $viewModel.password)
                            .textContentType(.password)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
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
                    
                    Button {
                        Task {
                            await viewModel.login()
                        }
                    } label: {
                        ZStack {
                            Text(viewModel.isLoading ? "Giriş yapılıyor..." : "Giriş Yap")
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
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: 16) {
            HStack {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 1)
                
                Text("veya")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 1)
            }
            
            VStack(spacing: 12) {
                SignInWithAppleButton(.continue,
                    onRequest: { request in
                        viewModel.loginWithApple(request: request)
                    },
                    onCompletion: { result in
                        Task {
                            await viewModel.handleAppleSignInResult(result)
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(viewModel.isLoading)
                
                Button {
                    Task {
                        await viewModel.loginWithGoogle()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image("google")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Google ile Devam Et")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .foregroundStyle(Color.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
                .disabled(viewModel.isLoading)
                
                Button {
                    // TODO: Continue as Guest
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 20))
                        Text("Misafir Olarak Devam Et")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.1))
                    .foregroundStyle(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
    
    private var signUpPrompt: some View {
        HStack {
            Text("Hesabınız yok mu?")
                .font(.footnote)
                .foregroundColor(.secondary)
            Button("Kayıt Ol") {
                router.push(.register)
            }
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundStyle(.blue)
        }
        .padding(.bottom, 32)
    }
}

#Preview {
    LoginView()
        .environmentObject(Router())
}
