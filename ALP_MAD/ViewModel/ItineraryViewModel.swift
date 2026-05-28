//
//  ItineraryViewModel.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit

@Observable
final class ItineraryViewModel {
    private var modelContext: ModelContext
    var selectedTrip: Trip?
    
    // State posisi kamera peta (MapKit)
    var cameraPosition: MapCameraPosition = .automatic

    init(modelContext: ModelContext, trip: Trip? = nil) {
        self.modelContext = modelContext
        self.selectedTrip = trip
        updateCameraPosition()
    }

    // Mengambil destinasi yang sudah diurutkan berdasarkan urutan kunjungan
    var sortedDestinations: [Destination] {
        guard let selectedTrip else { return [] }
        return selectedTrip.destinations.sorted { $0.visitOrder < $1.visitOrder }
    }

    // C - Create Destinasi Baru
    func addDestination(name: String, latitude: Double, longitude: Double, isUMKM: Bool) {
        guard let selectedTrip else { return }
        let nextOrder = selectedTrip.destinations.count + 1
        
        let destination = Destination(name: name, latitude: latitude, longitude: longitude, isLocalUMKM: isUMKM, visitOrder: nextOrder)
        selectedTrip.destinations.append(destination)
        
        saveAndRefresh()
    }

    // U - Update (Mengatur Ulang Urutan Destinasi Melalui Drag & Drop)
    func moveDestination(from source: IndexSet, to destination: Int) {
        var items = sortedDestinations
        items.move(fromOffsets: source, toOffset: destination)
        
        // Memperbarui urutan indeks pasca pergeseran posisi
        for (index, item) in items.enumerated() {
            item.visitOrder = index + 1
        }
        
        saveAndRefresh()
    }

    // D - Delete Destinasi
    func deleteDestination(at offsets: IndexSet) {
        guard let selectedTrip else { return }
        let sortedItems = sortedDestinations
        
        for index in offsets {
            let itemToDelete = sortedItems[index]
            selectedTrip.destinations.removeAll { $0.id == itemToDelete.id }
            modelContext.delete(itemToDelete)
        }
        
        // Menata ulang nomor urutan kunjungan setelah ada yang dihapus
        for (index, item) in sortedDestinations.enumerated() {
            item.visitOrder = index + 1
        }
        
        saveAndRefresh()
    }

    // Otomatisasi fokus kamera berdasarkan marker koordinat yang ada
    func updateCameraPosition() {
        let destinations = sortedDestinations
        guard !destinations.isEmpty else {
            // Default koordinat ke pusat Universitas Ciputra Surabaya jika kosong
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -7.2856, longitude: 112.6312),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            return
        }
        
        let coordinates = destinations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        if let firstLocation = coordinates.first {
            cameraPosition = .region(MKCoordinateRegion(
                center: firstLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            ))
        }
    }

    private func saveAndRefresh() {
        try? modelContext.save()
        updateCameraPosition()
    }
}
