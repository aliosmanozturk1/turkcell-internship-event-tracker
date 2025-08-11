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
    @StateObject private var searchCompleter = SearchCompleter()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar

                if !searchCompleter.results.isEmpty {
                    List(searchCompleter.results, id: \.self) { completion in
                        Button {
                            selectCompletion(completion)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(completion.title)
                                if !completion.subtitle.isEmpty {
                                    Text(completion.subtitle)
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
                .onChange(of: searchQuery) { newValue in
                    searchCompleter.update(query: newValue)
                }
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
            if let item = response?.mapItems.first {
                setRegion(to: item)
            }
        }
        searchCompleter.results.removeAll()
    }

    private func selectCompletion(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            if let item = response?.mapItems.first {
                setRegion(to: item)
                searchQuery = item.name ?? completion.title
            }
        }
        searchCompleter.results.removeAll()
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

final class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
    }

    func update(query: String) {
        completer.queryFragment = query
    }

    func completer(_ completer: MKLocalSearchCompleter, didUpdateResults results: [MKLocalSearchCompletion]) {
        self.results = results
    }
}
