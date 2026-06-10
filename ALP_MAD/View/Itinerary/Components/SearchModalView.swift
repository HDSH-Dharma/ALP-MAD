//
// SearchModalView.swift
// ALP_MAD
//
// Created by student on 10/06/26.
//

import SwiftUI
import SwiftData

struct SearchModalView: View {
    @ObservedObject var viewModel: ItineraryViewModel
    let onSelectPlace: (LandmarkPlace) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBarView(
                    searchText: $searchText,
                    onSubmit: {
                        viewModel.searchText = searchText
                        viewModel.performSearch()
                    },
                    onClear: {
                        searchText = ""
                        viewModel.clearSearch()
                    }
                )
                
                // Search results
                SearchResultsView(
                    viewModel: viewModel,
                    searchText: searchText,
                    onSelectPlace: onSelectPlace
                )
                
                Spacer()
            }
            .navigationTitle("Cari Tempat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") {
                        dismiss()
                    }
                    .foregroundColor(.themeBlue)
                }
            }
        }
    }
}

// MARK: - SEARCH BAR VIEW
struct SearchBarView: View {
    @Binding var searchText: String
    let onSubmit: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Cari tempat...", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(.themeDarkText)
                .onChange(of: searchText) { _, newValue in
                    if newValue.count >= 2 {
                        onSubmit()
                    } else if newValue.isEmpty {
                        onClear()
                    }
                }
                .onSubmit(onSubmit)
            
            if !searchText.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            Color(.systemGray6)
                .cornerRadius(10)
        )
        .padding()
    }
}

// MARK: - SEARCH RESULTS VIEW
struct SearchResultsView: View {
    @ObservedObject var viewModel: ItineraryViewModel
    let searchText: String
    let onSelectPlace: (LandmarkPlace) -> Void
    
    var body: some View {
        if viewModel.isSearching {
            ProgressView("Mencari...")
                .padding()
        } else if !viewModel.searchResults.isEmpty {
            List(viewModel.searchResults) { place in
                Button(action: {
                    onSelectPlace(place)
                }) {
                    SearchResultRow(place: place)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(.plain)
        } else if searchText.count >= 2 {
            NoResultsView(searchText: searchText)
        } else {
            InitialSearchStateView()
        }
    }
}

// MARK: - SEARCH RESULT ROW
struct SearchResultRow: View {
    let place: LandmarkPlace
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.themeGold)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.themeDarkText)
                Text(place.shortDesc)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - NO RESULTS VIEW
struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text("Tidak ada hasil untuk \"\(searchText)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
}

// MARK: - INITIAL SEARCH STATE VIEW
struct InitialSearchStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "map.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text("Ketik minimal 2 huruf untuk mencari tempat")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    let dummyTrip = Trip(title: "Test", startDate: Date(), endDate: Date())
    container.mainContext.insert(dummyTrip)
    
    let viewModel = ItineraryViewModel(modelContext: container.mainContext, trip: dummyTrip)
    
    return SearchModalView(viewModel: viewModel) { place in
        print("Selected: \(place.name)")
    }
}
