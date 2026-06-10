//
//  ItineraryMainView.swift
//  ALP_MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI
import SwiftData

struct ItineraryMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate) private var trips: [Trip]
    @State private var isShowingAddItinerary = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if trips.isEmpty {
                    ContentUnavailableView(
                        "Belum Ada Itinerary",
                        systemImage: "map.fill",
                        description: Text("Tekan tombol + untuk merencanakan liburan pertama Anda.")
                    )
                } else {
                    List {
                        ForEach(trips) { trip in
                            NavigationLink(destination: TripDaysDetailView(trip: trip)) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.themeTurquoiseLight)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "airplane.departure")
                                            .foregroundColor(.themeTeal)
                                            .font(.title3)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(trip.title)
                                            .font(.headline)
                                            .foregroundColor(.themeDarkText)
                                        Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteTrip)
                    }
                }
            }
            .navigationTitle("Itinerary")
            .toolbar {
                Button(action: { isShowingAddItinerary.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.themeGold) // Menggunakan Gold agar mencolok
                }
            }
            .sheet(isPresented: $isShowingAddItinerary) {
                AddItineraryColumnView()
            }
        }
        .tint(.themeTeal)
    }
    
    private func deleteTrip(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(trips[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    let dummyTrip = Trip(title: "Eksplorasi Surabaya", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 2))
    container.mainContext.insert(dummyTrip)
    
    return ItineraryMainView()
        .modelContainer(container)
}
