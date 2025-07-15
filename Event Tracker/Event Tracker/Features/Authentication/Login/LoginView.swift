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
            Color(hex: "F2F1EC")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                Text("Welcome")
                    .font(.largeTitle)
                
                Spacer()
                
                TextField("E-Mail", text: $viewModel.email)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                }
                                    
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 5)
                }
                
                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    Text("Login")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "283C5F"))
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                HStack {
                    Text("Don't have an account yet?")
                    Button("Sign Up") {
                        router.push(.register)
                    }
                    .foregroundStyle(Color(hex: "1D40B0"))
                }
                
                Spacer()
                
                SignInWithAppleButton(.signIn) { request in
                    viewModel.prepareAppleRequest(request)
                } onCompletion: { result in
                    Task {
                        await viewModel.loginWithApple(result: result)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button {
                    Task {
                        await viewModel.loginWithGoogle()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Image("google")
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text("Continue with Google")
                            .bold()
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "000000"))
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(viewModel.isLoading)
                
                Button {
                    // TODO: Continue as Guest
                } label: {
                    Text("Continue as Guest")
                        .bold()
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "FEF3C7"))
                        .foregroundStyle(Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        // RootView will switch views when user logs in
    }
}

#Preview {
    LoginView()
        .environmentObject(Router())
}
