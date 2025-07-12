//
//  MainView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 10.07.2025.
//


import SwiftUI

struct MainView: View {
    let userEmail: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "F2F1EC")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Hoşgeldiniz!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "283C5F"))
                
                Text("Welcome to Event Tracker!")
                    .font(.title2)
                    .foregroundColor(Color(hex: "283C5F"))
                
                VStack(spacing: 10) {
                    Text("Giriş yapılan email:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(userEmail)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "283C5F"))
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Main Page")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sign Out") {
                    viewModel.signOut()
                    dismiss()
                }
                .disabled(viewModel.isSigningOut)
            }
        }
    }
}

#Preview {
    MainView(userEmail: "test@example.com")
}

