//
//  EventView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI

struct EventView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
                    Text("Başlık")
                        .font(.headline)
                    Text("Açıklama metni buraya gelecek.")
                        .font(.subheadline)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(radius: 5)
                )
                .padding(.horizontal)
    }
}

#Preview {
    EventView()
}
