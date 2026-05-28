//
//  TripDashboardView.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import SwiftUI
import SwiftData

struct TripDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Mengambil data seluruh Trip dari SwiftData, diurutkan berdasarkan tanggal terdekat
    @Query(sort: \Trip.startDate, order: .forward) private var trips: [Trip]
    
    // Status untuk mengontrol tampilan sheet tambah trip baru
    @State private var showingAddTripSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    // Tampilan jika belum ada trip yang dibuat (Empty State)
                    ContentUnavailableView(
                        "Belum Ada Perjalanan",
                        systemImage: "airplane.departure",
                        description: Text("Mulai petualangan Anda dengan membuat rencana perjalanan mandiri yang mendukung ekonomi lokal.")
                    )
                } else {
                    // Daftar Trip yang tersedia
                    List {
                        ForEach(trips) { trip in
                            NavigationLink(destination: ItineraryCanvasView(trip: trip, modelContext: modelContext)) {
                                TripRowComponent(trip: trip)
                            }
                        }
                        .onDelete(perform: deleteTrips) // Fungsi hapus trip lewat swipe-to-delete
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Project Swift 🎒")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddTripSheet.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            // Sheet Pop-up Form untuk Tambah Trip Baru
            .sheet(isPresented: $showingAddTripSheet) {
                AddTripSheetView()
            }
        }
    }
    
    // Fungsi CRUD: Menghapus Trip dari database lokal SwiftData
    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            let tripToDelete = trips[index]
            modelContext.delete(tripToDelete)
        }
        try? modelContext.save()
    }
}

// MARK: - SUB KOMPONEN: BARIS DAFTAR TRIP (TripRowComponent)
struct TripRowComponent: View {
    let trip: Trip
    
    var body: some View {
        HStack(spacing: 16) {
            // Ikon dekoratif bertema travel
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: "suitcase.rolling.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Format rentang tanggal perjalanan
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text("\(formatDate(trip.startDate)) - \(formatDate(trip.endDate))")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                // Indikator jumlah destinasi yang terdaftar di dalam trip
                Text("📍 \(trip.destinations.count) Destinasi")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(trip.destinations.isEmpty ? .secondary : .green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(trip.destinations.isEmpty ? Color(.systemGray6) : Color.green.opacity(0.1))
                    .cornerRadius(4)
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - SUB VIEW: SHEET TAMBAH TRIP BARU (AddTripSheetView)
struct AddTripSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tripTitle: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400) // Default +1 hari
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informasi Utama")) {
                    TextField("Nama Perjalanan (Contoh: Eksplorasi Surabaya)", text: $tripTitle)
                }
                
                Section(header: Text("Waktu Pelaksanaan")) {
                    DatePicker("Tanggal Mulai", selection: $startDate, displayedComponents: .date)
                    DatePicker("Tanggal Selesai", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("Buat Rencana Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        // Logika CRUD: Menyimpan trip baru ke SwiftData
                        let newTrip = Trip(title: tripTitle.trimmingCharacters(in: .whitespacesAndNewlines), startDate: startDate, endDate: endDate)
                        modelContext.insert(newTrip)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(tripTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - SWIFTUI PREVIEW BLOCK (SwiftData In-Memory)
#Preview {
    // 1. Membuat konfigurasi kontainer database tiruan di memori RAM
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    
    // 2. Menyiapkan Mock Data Trip Contoh (Sesuai tema proposal Kelompok 6)
    let mockTrip1 = Trip(title: "Kunjungan Universitas Ciputra 🎓", startDate: Date(), endDate: Date().addingTimeInterval(86400))
    let mockTrip2 = Trip(title: "Eksplorasi Kuliner Wisata Lokal Surabaya", startDate: Date().addingTimeInterval(86400 * 3), endDate: Date().addingTimeInterval(86400 * 5))
    
    // Tambahkan destinasi tiruan ke dalam Trip 1 agar tampilan badge terisi
    let mockDest = Destination(name: "Sentra Wisata Kuliner GWalk", latitude: -7.2891, longitude: 112.6415, isLocalUMKM: true, visitOrder: 1)
    mockTrip1.destinations.append(mockDest)
    
    // Masukkan data tiruan ke konteks utama
    container.mainContext.insert(mockTrip1)
    container.mainContext.insert(mockTrip2)
    
    return TripDashboardView()
        .modelContainer(container)
}
