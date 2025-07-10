//
//  RegisterView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 9.07.2025.
//

import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""
    
    var body: some View {
        ZStack {
            Color(hex: "F2F1EC")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                Text("Register")
                    .font(.largeTitle)
                
                Spacer()
                
                TextField("E-Mail", text: $email)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                SecureField("Re-Enter Password", text: $repeatPassword)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button {
                    // TODO: Login Button Action
                } label: {
                    Text("Register")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "283C5F"))
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RegisterView()
}
