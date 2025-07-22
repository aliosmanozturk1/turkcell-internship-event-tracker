//
//  ProfileView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI

struct ProfileView: View {
    let userEmail: String
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack {
            Color(hex: "F2F1EC")
                .edgesIgnoringSafeArea(.all)

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
                
                Spacer()
                
                Button {
                    sessionManager.signOut()
                } label: {
                    Text("Sign Out")
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
            }
            .padding(.top, 50)
            .padding(.bottom, 50)
            .padding()
        }
    }
}

#Preview {
    ProfileView(userEmail: "test@example.com")
        .environmentObject(SessionManager())
}
