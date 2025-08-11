//
//  LocationPickerView.swift
//  Event Tracker
//
//  Created by Ali Osman Öztürk on 11.08.2025.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var latitude: String
    @Binding var longitude: String

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.015137, longitude: 28.97953),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchQuery = ""
    @State private var searchResults: [MKMapItem] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar

                if !searchResults.isEmpty {
                    List(searchResults, id: \.self) { item in
                        Button {
                            setRegion(to: item)
                            searchResults.removeAll()
                            searchQuery = item.name ?? ""
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.name ?? "")
                                if let subtitle = item.placemark.title {
                                    Text(subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                ZStack {
                    Map(coordinateRegion: $region, showsUserLocation: true)
                        .ignoresSafeArea()
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }

                Button("Konumu Seç") {
                    latitude = String(region.center.latitude)
                    longitude = String(region.center.longitude)
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("Konum Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            TextField("Konum ara", text: $searchQuery, onCommit: performSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: performSearch) {
                Image(systemName: "magnifyingglass")
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            searchResults = response?.mapItems ?? []
        }
    }

    private func setRegion(to item: MKMapItem) {
        withAnimation {
            region = MKCoordinateRegion(
                center: item.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}
