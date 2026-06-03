//
//  AddCuratedDestinationSheet.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import SwiftUI
import SwiftData

struct AddItineraryColumnView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tripTitle = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 2)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tujuan Perjalanan") {
                    TextField("Nama Liburan (contoh: Explore Bali)", text: $tripTitle)
                }
                
                Section("Jadwal") {
                    DatePicker("Mulai", selection: $startDate, displayedComponents: .date)
                        .tint(.themeTeal)
                    DatePicker("Selesai", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .tint(.themeTeal)
                }
            }
            .navigationTitle("Buat Itinerary Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                        .foregroundColor(.themeDarkText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lanjut") {
                        let newTrip = Trip(title: tripTitle, startDate: startDate, endDate: endDate)
                        modelContext.insert(newTrip)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(tripTitle.isEmpty)
                    .foregroundColor(tripTitle.isEmpty ? .gray : .themeTeal)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    return AddItineraryColumnView().modelContainer(container)
}
