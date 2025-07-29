//
//  EventView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 22.07.2025.
//

import SwiftUI

struct EventView: View {
    @StateObject private var viewModel = EventViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.events) { event in
                    EventCardView(event: event)
                }
            }
            .padding()
        }
        .onAppear {
            if viewModel.events.isEmpty {
                Task { await viewModel.loadEvents() }
            }
        }
    }
}

#Preview {
    EventView()
}
