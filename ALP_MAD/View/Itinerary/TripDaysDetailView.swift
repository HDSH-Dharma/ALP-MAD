//
//  TripDaysDetailView.swift
//  ALP_MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI
import SwiftData

struct TripDaysDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var trip: Trip
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(trip.title)
                        .font(.title2)
                        .bold()
                    Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Pilih Hari Untuk Dijadwalkan").foregroundColor(.roseGoldDark)) {
                ForEach(1...trip.totalDays, id: \.self) { day in
                    NavigationLink(destination: InteractiveCanvasView(trip: trip, dayNumber: day, context: modelContext)) {
                        HStack {
                            ZStack {
                                Circle().fill(Color.roseGoldLight).frame(width: 36, height: 36)
                                Text("\(day)").font(.headline).foregroundColor(.roseGoldDark)
                            }
                            Text("Hari Ke-\(day)")
                                .fontWeight(.medium)
                                .padding(.leading, 8)
                            Spacer()
                            
                            let count = trip.destinations.filter { $0.dayNumber == day }.count
                            if count > 0 {
                                Text("\(count) Tempat")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.roseGoldLight.opacity(0.5))
                                    .foregroundColor(.roseGoldDark)
                                    .clipShape(Capsule())
                            } else {
                                Text("Kosong")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Daftar Hari")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - PREVIEW
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    
    let dummyTrip = Trip(title: "Explore Bali", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 3))
    
    // Tambah 1 destinasi dummy agar badge "1 Tempat" muncul di Hari Ke-1
    let dummyDest = Destination(name: "Pantai Kuta", latitude: -8.7179, longitude: 115.1695, isLocalUMKM: false, visitOrder: 0, dayNumber: 1)
    dummyTrip.destinations.append(dummyDest)
    
    container.mainContext.insert(dummyTrip)
    
    return NavigationStack {
        TripDaysDetailView(trip: dummyTrip)
    }
    .modelContainer(container)
}
