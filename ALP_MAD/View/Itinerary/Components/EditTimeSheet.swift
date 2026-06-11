//
// EditTimeSheet.swift
// ALP_MAD
//
// Created by student on 10/06/26.
//

import SwiftUI
import SwiftData

struct EditTimeSheet: View {
    let destination: Destination
    @ObservedObject var viewModel: ItineraryViewModel
    let onSave: (String) -> Void
    let onCancel: () -> Void
    let onDelete: () -> Void
    let errorMessage: String?
    
    @State private var selectedTime: Date
    
    init(
        destination: Destination,
        viewModel: ItineraryViewModel,
        onSave: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        errorMessage: String?
    ) {
        self.destination = destination
        self.viewModel = viewModel
        self.onSave = onSave
        self.onCancel = onCancel
        self.onDelete = onDelete
        self.errorMessage = errorMessage
        
        // Parse existing time string
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: destination.timeString) {
            _selectedTime = State(initialValue: date)
        } else {
            _selectedTime = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Destination info section
                DestinationInfoSection(destination: destination)
                
                // Time selection section
                EditTimeSelectionSection(
                    selectedTime: $selectedTime,
                    errorMessage: errorMessage
                )
                
                // Info section
                EditInfoSection()
                
                // Delete section
                DeleteSection(onDelete: onDelete)
            }
            .navigationTitle("Edit Jadwal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        onCancel()
                    }
                    .foregroundColor(.themeDarkText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        let timeString = formatTime(selectedTime)
                        onSave(timeString)
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.themeTeal)
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - DESTINATION INFO SECTION
struct DestinationInfoSection: View {
    let destination: Destination
    
    var body: some View {
        Section("Tempat") {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.themeGold.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text("\(destination.visitOrder + 1)")
                        .font(.headline.bold())
                        .foregroundColor(.themeGold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.name)
                        .font(.headline)
                        .foregroundColor(.themeDarkText)
                    if !destination.activityDesc.isEmpty {
                        Text(destination.activityDesc)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
    }
}

// MARK: - EDIT TIME SELECTION SECTION
struct EditTimeSelectionSection: View {
    @Binding var selectedTime: Date
    let errorMessage: String?
    
    var body: some View {
        Section("Waktu Kunjungan") {
            DatePicker(
                "Jam",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .tint(.themeTeal)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - EDIT INFO SECTION
struct EditInfoSection: View {
    var body: some View {
        Section {
            Text("Urutan kunjungan akan otomatis disesuaikan berdasarkan waktu yang Anda pilih.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - DELETE SECTION
struct DeleteSection: View {
    let onDelete: () -> Void
    
    var body: some View {
        Section {
            Button(role: .destructive) {
                onDelete()
            } label: {
                HStack {
                    Spacer()
                    Text("Hapus dari Itinerary")
                        .fontWeight(.medium)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    
    let dummyTrip = Trip(title: "Test", startDate: Date(), endDate: Date())
    container.mainContext.insert(dummyTrip)
    
    let dest = Destination(
        name: "Tugu Pahlawan",
        latitude: -7.2458,
        longitude: 112.7378,
        isLocalUMKM: false,
        visitOrder: 0,
        dayNumber: 1,
        timeString: "09:00",
        activityDesc: "Monumen bersejarah perjuangan pahlawan."
    )
    container.mainContext.insert(dest)  // ← wajib
    dummyTrip.destinations.append(dest)
    
    let viewModel = ItineraryViewModel(modelContext: container.mainContext, trip: dummyTrip)
    
    return EditTimeSheet(
        destination: dest,
        viewModel: viewModel,
        onSave: { print("Saved: \($0)") },
        onCancel: { print("Cancelled") },
        onDelete: { print("Deleted") },
        errorMessage: nil
    )
    .modelContainer(container)  // ← wajib
}
