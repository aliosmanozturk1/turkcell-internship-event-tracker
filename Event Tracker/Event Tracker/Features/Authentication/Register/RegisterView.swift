//
//  RegisterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 9.07.2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "F2F1EC")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                Text("Register")
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
                
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
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
                        await viewModel.register()
                    }
                } label: {
                    Text("Register")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "283C5F"))
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(viewModel.isLoading)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.isRegistered) {
            MainView(userEmail: viewModel.email)
        }
    }
}

#Preview {
    RegisterView()
}
