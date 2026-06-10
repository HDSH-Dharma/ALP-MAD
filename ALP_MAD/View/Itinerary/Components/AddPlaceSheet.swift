//
// AddPlaceSheet.swift
// ALP_MAD
//
// Created by student on 10/06/26.
//

import SwiftUI
import SwiftData

struct AddPlaceSheet: View {
    let place: LandmarkPlace
    @ObservedObject var viewModel: ItineraryViewModel
    let onAdd: (String) -> Void
    let onCancel: () -> Void
    let errorMessage: String?
    
    @State private var selectedTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        return calendar.date(bySettingHour: 10, minute: 0, second: 0, of: calendar.date(from: components)!)!
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                // Place info section
                PlaceInfoSection(place: place)
                
                // Time selection section
                TimeSelectionSection(
                    selectedTime: $selectedTime,
                    errorMessage: errorMessage
                )
                
                // Info section
                InfoSection()
            }
            .navigationTitle("Tambahkan Tempat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        onCancel()
                    }
                    .foregroundColor(.themeDarkText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tambah") {
                        let timeString = formatTime(selectedTime)
                        onAdd(timeString)
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

// MARK: - PLACE INFO SECTION
struct PlaceInfoSection: View {
    let place: LandmarkPlace
    
    var body: some View {
        Section("Tempat") {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.themeTurquoiseLight)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: place.isUMKM ? "storefront" : "mappin")
                            .foregroundColor(.themeTeal)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.headline)
                        .foregroundColor(.themeDarkText)
                    if place.isUMKM {
                        Text("SDG 8: UMKM Lokal")
                            .font(.caption2).bold()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.themeGold.opacity(0.2))
                            .foregroundColor(.themeGold)
                            .cornerRadius(4)
                    }
                    Text(place.shortDesc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
    }
}

// MARK: - TIME SELECTION SECTION
struct TimeSelectionSection: View {
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

// MARK: - INFO SECTION
struct InfoSection: View {
    var body: some View {
        Section {
            Text("Urutan kunjungan akan otomatis disesuaikan berdasarkan waktu yang Anda pilih.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let place = LandmarkPlace(
        name: "Tugu Pahlawan",
        latitude: -7.2458,
        longitude: 112.7378,
        shortDesc: "Monumen bersejarah perjuangan pahlawan.",
        isUMKM: false
    )
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    let dummyTrip = Trip(title: "Test", startDate: Date(), endDate: Date())
    container.mainContext.insert(dummyTrip)
    
    let viewModel = ItineraryViewModel(modelContext: container.mainContext, trip: dummyTrip)
    
    return AddPlaceSheet(
        place: place,
        viewModel: viewModel,
        onAdd: { time in
            print("Added at \(time)")
        },
        onCancel: {
            print("Cancelled")
        },
        errorMessage: nil
    )
}
