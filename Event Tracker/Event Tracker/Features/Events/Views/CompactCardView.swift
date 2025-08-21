//
//  CompactCardView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 21.08.2025.
//

import SwiftUI

struct CompactCardView: View {
    @StateObject private var viewModel: CompactCardViewModel
    @EnvironmentObject private var router: Router
    
    init(event: CreateEventModel) {
        _viewModel = StateObject(wrappedValue: CompactCardViewModel(event: event))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: viewModel.thumbnailImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack {
                    
                    Text(viewModel.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(viewModel.formattedPrice)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.priceColor)
                        .padding(.trailing, 10)
                }
                
            }
            
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            router.push(.eventDetail(viewModel.event))
        }
    }
}
