//
//  LoginView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 9.07.2025.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        
        ZStack {
            Color(hex: "F2F1EC")
                .edgesIgnoringSafeArea(.all)
            
            VStack (spacing: 10) {
                Text("Welcome")
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
                
                Button {
                    // TODO: Login Button Action
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
                        // TODO: Register Button Action
                    }
                    .foregroundStyle(Color(hex: "1D40B0"))
                }
                
                Spacer()
                
                Button {
                    // TODO: Continue With Apple
                } label: {
                    HStack (alignment: .center) {
                        Image(systemName: "apple.logo")
                        Text("Continue with Apple")
                            .bold()
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "000000"))
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    // TODO: Continue With Google
                } label: {
                    HStack (alignment: .center) {
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
        
    }
}

#Preview {
    LoginView()
}
