//
//  SplashView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 19.07.2025.
//

import Lottie
import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            LottieView(animation: .named("heart"))
                .playing(loopMode: .playOnce)
                .resizable()
                .frame(maxWidth: .infinity)
                .padding(100)
        }
    }
}

#Preview {
    SplashScreenView()
}
