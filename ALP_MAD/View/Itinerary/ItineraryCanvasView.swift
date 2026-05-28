//
//  ItineraryCanvasView.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import SwiftUI
import MapKit
import SwiftData

struct ItineraryCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ItineraryViewModel
    @State private var showingAddSheet = false
    
    // Deteksi ukuran layar gawai (iPhone vs iPad) untuk layout adaptif
    @Environment(\.horizontalSizeClass) var sizeClass

    init(trip: Trip, modelContext: ModelContext) {
        _viewModel = State(initialValue: ItineraryViewModel(modelContext: modelContext, trip: trip))
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                // Tampilan untuk iPad (Layar Lebar - Side by Side)
                HStack(spacing: 0) {
                    itinerarySidebarList
                        .frame(width: 380)
                    Divider()
                    mapCanvasComponent
                }
            } else {
                // Tampilan untuk iPhone (Layar Ringkas - Atas Bawah)
                VStack(spacing: 0) {
                    mapCanvasComponent
                        .frame(height: 320)
                    Divider()
                    itinerarySidebarList
                }
            }
        }
        .navigationTitle(viewModel.selectedTrip?.title ?? "Itinerary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddSheet.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCuratedDestinationSheet(viewModel: viewModel)
        }
    }

    // MARK: - Sub Komponen Peta Interaktif
    private var mapCanvasComponent: some View {
        Map(position: $viewModel.cameraPosition) {
            ForEach(viewModel.sortedDestinations) { destination in
                // Memberikan pin pembeda warna: Hijau untuk UMKM Lokal (SDG 8), Biru untuk Wisata Umum
                Marker(
                    "\(destination.visitOrder). \(destination.name)",
                    coordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
                )
                .tint(destination.isLocalUMKM ? .green : .blue)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
    }

    // MARK: - Sub Komponen Daftar Urutan Perjalanan
    private var itinerarySidebarList: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.sortedDestinations.isEmpty {
                ContentUnavailableView(
                    "Rencana Kosong",
                    systemImage: "map.badge.ellipsis",
                    description: Text("Mulai rencanakan perjalanan mandiri Anda dengan menambahkan destinasi lokal.")
                )
            } else {
                List {
                    ForEach(viewModel.sortedDestinations) { destination in
                        HStack(spacing: 12) {
                            // Badge nomor urutan
                            ZStack {
                                Circle()
                                    .fill(destination.isLocalUMKM ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                                    .frame(width: 30, height: 30)
                                Text("\(destination.visitOrder)")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(destination.isLocalUMKM ? .green : .blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(destination.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                if destination.isLocalUMKM {
                                    Text("🏪 UMKM Lokal Pilihan")
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(.green)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete(perform: viewModel.deleteDestination) // CRUD: Hapus destinasi
                    .onMove(perform: viewModel.moveDestination)     // CRUD: Atur urutan lewat drag & drop
                }
                .environment(\.editMode, .constant(.active)) // Memunculkan opsi drag handle langsung di list
            }
        }
    }
}

// MARK: - SEKSI SWIFTUI PREVIEW
#Preview {
    // 1. Membuat konfigurasi kontainer SwiftData tiruan di dalam memori semata (In-Memory)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    
    // 2. Inisialisasi data tiruan (Mock Data) untuk visualisasi Canvas Preview
    let mockTrip = Trip(
        title: "Eksplorasi Surabaya Barat 🎒",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 2) // Durasi 2 hari
    )
    
    // Masukkan mock trip ke dalam context pratinjau
    container.mainContext.insert(mockTrip)
    
    // 3. Menambahkan beberapa destinasi contoh (Kombinasi Wisata Umum & UMKM sesuai proposal Anda)
    let destination1 = Destination(name: "Universitas Ciputra Surabaya", latitude: -7.2856, longitude: 112.6312, isLocalUMKM: false, visitOrder: 1)
    let destination2 = Destination(name: "Sentra Wisata Kuliner GWalk", latitude: -7.2891, longitude: 112.6415, isLocalUMKM: true, visitOrder: 2)
    let destination3 = Destination(name: "Pasar Modern Jajanan Citraland", latitude: -7.2872, longitude: 112.6350, isLocalUMKM: true, visitOrder: 3)
    
    mockTrip.destinations.append(destination1)
    mockTrip.destinations.append(destination2)
    mockTrip.destinations.append(destination3)
    
    // 4. Mengembalikan View utama yang dibungkus dengan kontainer preview
    return NavigationStack {
        ItineraryCanvasView(trip: mockTrip, modelContext: container.mainContext)
    }
    .modelContainer(container)
}
