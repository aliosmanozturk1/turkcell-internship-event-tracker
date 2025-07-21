//
//  CompleteProfileView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.07.2025.
//

import SwiftUI

struct CompleteProfileView: View {
    @StateObject private var viewModel = CompleteProfileViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "F2F1EC")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                TextField("Lütfen adınızı girin", text: $viewModel.firstName)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                TextField("Lütfen soyadınızı girin", text: $viewModel.lastName)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button {} label: {
                    Text("Kaydet")
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "283C5F"))
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
              }
            .padding()
         }
    }
}

#Preview {
    CompleteProfileView()
}
