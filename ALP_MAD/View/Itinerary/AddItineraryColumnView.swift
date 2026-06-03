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
    
    // Updated and added states to match the Trip model properties
    @State private var tripName = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 2)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tujuan Perjalanan") {
                    TextField("Nama Liburan (contoh: Explore Bali)", text: $tripName)
                    
                    // Added destination field required by the Trip model
                    TextField("Lokasi Tujuan (contoh: Bali)", text: $destination)
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
                        // ADJUSTED: Uses 'name' and passes the 'destination' string
                        let newTrip = Trip(
                            name: tripName,
                            destination: destination,
                            startDate: startDate,
                            endDate: endDate
                        )
                        modelContext.insert(newTrip)
                        try? modelContext.save()
                        dismiss()
                    }
                    // Validation adjusted to check both inputs
                    .disabled(tripName.isEmpty || destination.isEmpty)
                    .foregroundColor((tripName.isEmpty || destination.isEmpty) ? .gray : .themeTeal)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, BudgetItem.self, configurations: config)
    return AddItineraryColumnView()
        .modelContainer(container)
}
