//
//  AddCuratedDestinationSheet.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import SwiftUI
import MapKit
import SwiftData

// Struktur data lokal khusus untuk menampung data katalog rekomendasi
struct CuratedSpot: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let isUMKM: Bool
    let description: String
}

struct AddCuratedDestinationSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // Menerima ViewModel dari parent view (ItineraryCanvasView)
    var viewModel: ItineraryViewModel

    // State untuk menampung input manual dari pengguna
    @State private var inputName: String = ""
    @State private var markAsUMKM: Bool = false
    
    // State tambahan untuk melacak destinasi katalog mana yang sedang dipilih
    @State private var selectedCatalogSpotID: UUID? = nil

    // Kumpulan katalog rekomendasi lokal sekitar lokasi Surabaya Barat (Sesuai tema SDG 8 Kelompok 6)
    let curatedHiddenGems: [CuratedSpot] = [
        CuratedSpot(name: "Sentra Wisata Kuliner GWalk", latitude: -7.2891, longitude: 112.6415, isUMKM: true, description: "Pusat kuliner lokal yang memberdayakan ratusan pedagang UMKM makanan khas."),
        CuratedSpot(name: "Pasar Modern Citraland", latitude: -7.2872, longitude: 112.6350, isUMKM: true, description: "Tempat berbelanja bahan organik dan jajanan pasar tradisional dari produsen lokal."),
        CuratedSpot(name: "Hutan Kota Pakal Surabaya", latitude: -7.2452, longitude: 112.6012, isUMKM: false, description: "Destinasi wisata hijau publik yang ramah lingkungan dan bebas biaya masuk."),
        CuratedSpot(name: "Sentra Kerajinan Tangan Sambikerep", latitude: -7.2610, longitude: 112.6241, isUMKM: true, description: "Pusat oleh-oleh kerajinan rajutan dan anyaman langsung dari perajin lokal Surabaya.")
    ]

    var body: some View {
        NavigationStack {
            Form {
                // SEKSI 1: INPUT MANUAL
                Section {
                    HStack {
                        Image(systemName: markAsUMKM ? "storefront.fill" : "mappin.and.ellipse")
                            .foregroundColor(markAsUMKM ? .green : .blue)
                            .font(.title3)
                            .frame(width: 30)
                        
                        TextField("Nama Tempat Wisata / Kuliner", text: $inputName)
                            .onChange(of: inputName) { _, _ in
                                // Jika user mengetik manual, hilangkan seleksi dari katalog rekomendasi
                                selectedCatalogSpotID = nil
                            }
                    }
                    
                    Toggle(isOn: $markAsUMKM) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dukung Usaha / UMKM Lokal")
                                .font(.body)
                            Text("Aktifkan jika tempat ini dikelola oleh komunitas/warga lokal (SDG 8).")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.green)
                } header: {
                    Text("Input Destinasi Mandiri")
                }
                
                // SEKSI 2: KATALOG REKOMENDASI (CURATED CATALOG)
                Section {
                    ForEach(curatedHiddenGems) { spot in
                        Button(action: {
                            // Autofill data ke dalam input form ketika katalog dipilih
                            inputName = spot.name
                            markAsUMKM = spot.isUMKM
                            selectedCatalogSpotID = spot.id
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: spot.isUMKM ? "storefront" : "map")
                                    .foregroundColor(spot.isUMKM ? .green : .blue)
                                    .padding(.top, 4)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(spot.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text(spot.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                // Indikator Checkmark jika item ini terpilih
                                if selectedCatalogSpotID == spot.id {
                                    Image(systemName: "checkmark.border.filled")
                                        .foregroundColor(spot.isUMKM ? .green : .blue)
                                        .font(.title3)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Katalog Terkurasi Wisata Lokal & UMKM")
                } footer: {
                    Text("Katalog ini dirancang khusus untuk mempromosikan pariwisata berkelanjutan dan memperkuat ekonomi lokal sesuai target SDG 8.9.")
                }
            }
            .navigationTitle("Tambah ke Itinerary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Tombol Batal
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                
                // Tombol Simpan
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        guard !inputName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        
                        let finalLat: Double
                        let finalLon: Double
                        
                        // Cek apakah item yang disimpan berasal dari katalog terpilih
                        if let matchedSpot = curatedHiddenGems.first(where: { $0.id == selectedCatalogSpotID }) {
                            finalLat = matchedSpot.latitude
                            finalLon = matchedSpot.longitude
                        } else {
                            // Jika input manual murni, kita buat koordinat acak tipis di sekitar pusat Surabaya Barat
                            finalLat = -7.2856 + Double.random(in: -0.015...0.015)
                            finalLon = 112.6312 + Double.random(in: -0.015...0.015)
                        }
                        
                        // Panggil fungsi create pada ViewModel
                        viewModel.addDestination(
                            name: inputName,
                            latitude: finalLat,
                            longitude: finalLon,
                            isUMKM: markAsUMKM
                        )
                        
                        dismiss() // Tutup sheet setelah berhasil menyimpan
                    }
                    .disabled(inputName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - SWIFTUI PREVIEW BLOCK
#Preview {
    // 1. Membuat konfigurasi container SwiftData tiruan (In-Memory)
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    
    // 2. Inisialisasi data Trip tiruan
    let mockTrip = Trip(
        title: "Kunjungan Universitas Ciputra 🎓",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400)
    )
    container.mainContext.insert(mockTrip)
    
    // 3. Inisialisasi ViewModel dengan context tiruan
    let mockViewModel = ItineraryViewModel(modelContext: container.mainContext, trip: mockTrip)
    
    // 4. Me-return View dengan melempar mockViewModel
    return AddCuratedDestinationSheet(viewModel: mockViewModel)
        .modelContainer(container)
}
