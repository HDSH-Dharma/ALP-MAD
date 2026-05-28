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
    
    var cameraPosition: MapCameraPosition = .automatic
    
    // Menyimpan status wilayah peta saat ini (dibutuhkan untuk fitur Zoom In/Out manual)
    var currentRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2856, longitude: 112.6312),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    init(modelContext: ModelContext, trip: Trip? = nil) {
        self.modelContext = modelContext
        self.selectedTrip = trip
        updateCameraPosition()
    }

    var sortedDestinations: [Destination] {
        guard let selectedTrip else { return [] }
        return selectedTrip.destinations.sorted { $0.visitOrder < $1.visitOrder }
    }

    // CRUD: Tambah Destinasi
    func addDestination(name: String, latitude: Double, longitude: Double, isUMKM: Bool) {
        guard let selectedTrip else { return }
        let nextOrder = selectedTrip.destinations.count + 1
        
        let destination = Destination(name: name, latitude: latitude, longitude: longitude, isLocalUMKM: isUMKM, visitOrder: nextOrder)
        selectedTrip.destinations.append(destination)
        
        saveAndRefresh()
    }

    // CRUD: Ubah Urutan (Drag & Drop)
    func moveDestination(from source: IndexSet, to destination: Int) {
        var items = sortedDestinations
        items.move(fromOffsets: source, toOffset: destination)
        
        for (index, item) in items.enumerated() {
            item.visitOrder = index + 1
        }
        
        saveAndRefresh()
    }

    // CRUD: Hapus Destinasi
    func deleteDestination(at offsets: IndexSet) {
        guard let selectedTrip else { return }
        let sortedItems = sortedDestinations
        
        for index in offsets {
            let itemToDelete = sortedItems[index]
            selectedTrip.destinations.removeAll { $0.id == itemToDelete.id }
            modelContext.delete(itemToDelete)
        }
        
        for (index, item) in sortedDestinations.enumerated() {
            item.visitOrder = index + 1
        }
        
        saveAndRefresh()
    }

    // Pemusatan Kamera Peta Otomatis
    func updateCameraPosition() {
        let destinations = sortedDestinations
        guard !destinations.isEmpty else {
            let defaultRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -7.2856, longitude: 112.6312),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            currentRegion = defaultRegion
            cameraPosition = .region(defaultRegion)
            return
        }
        
        let coordinates = destinations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        if let firstLocation = coordinates.first {
            let initialRegion = MKCoordinateRegion(
                center: firstLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            )
            currentRegion = initialRegion
            cameraPosition = .region(initialRegion)
        }
    }

    // Logika Zoom In (Memperkecil nilai Delta = Memperbesar Skala)
    func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: currentRegion.span.latitudeDelta * 0.5,
            longitudeDelta: currentRegion.span.longitudeDelta * 0.5
        )
        currentRegion.span = newSpan
        cameraPosition = .region(currentRegion)
    }
    
    // Logika Zoom Out (Memperbesar nilai Delta = Memperkecil Skala)
    func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: currentRegion.span.latitudeDelta * 2.0,
            longitudeDelta: currentRegion.span.longitudeDelta * 2.0
        )
        currentRegion.span = newSpan
        cameraPosition = .region(currentRegion)
    }

    private func saveAndRefresh() {
        try? modelContext.save()
        updateCameraPosition()
    }
}
