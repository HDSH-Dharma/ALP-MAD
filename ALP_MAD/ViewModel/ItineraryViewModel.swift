//
//  ItineraryViewModel.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData
import MapKit
import SwiftUI

@Observable
final class ItineraryViewModel {
    var modelContext: ModelContext
    var selectedTrip: Trip
    var selectedDay: Int = 1
    
    // MARK: - Search State (dipindahkan dari View)
    var searchText: String = ""
    var searchResults: [LandmarkPlace] = []
    var isSearching: Bool = false
    
    // MARK: - Discoverable Places (dipindahkan dari View)
    var discoverablePlaces: [LandmarkPlace] = [
        LandmarkPlace(name: "Tugu Pahlawan", latitude: -7.2458, longitude: 112.7378, shortDesc: "Monumen bersejarah perjuangan pahlawan.", isUMKM: false),
        LandmarkPlace(name: "Sentra Kuliner GWalk", latitude: -7.2891, longitude: 112.6415, shortDesc: "Pusat UMKM Kuliner warga lokal dengan cita rasa autentik.", isUMKM: true),
        LandmarkPlace(name: "Pasar Seni Lokal", latitude: -7.2531, longitude: 112.7401, shortDesc: "Oleh-oleh kerajinan tangan asli Suroboyo.", isUMKM: true)
    ]
    
    // MARK: - Zoom State (dipindahkan dari View)
    var currentZoomLevel: Double = 0.05
    
    init(modelContext: ModelContext, trip: Trip) {
        self.modelContext = modelContext
        self.selectedTrip = trip
    }
    
    // Filter destinasi hanya untuk hari yang dipilih
    var filteredDestinations: [Destination] {
        selectedTrip.destinations
            .filter { $0.dayNumber == selectedDay }
            .sorted { $0.visitOrder < $1.visitOrder }
    }
    
    func addDestination(place: LandmarkPlace) {
        let nextOrder = filteredDestinations.count
        let newDest = Destination(
            name: place.name,
            latitude: place.latitude,
            longitude: place.longitude,
            isLocalUMKM: place.isUMKM,
            visitOrder: nextOrder,
            dayNumber: selectedDay,
            timeString: "10:00", // Default waktu
            activityDesc: place.shortDesc
        )
        selectedTrip.destinations.append(newDest)
        saveContext()
    }
    
    func deleteDestination(at offsets: IndexSet) {
        let itemsForDay = filteredDestinations
        for index in offsets {
            let itemToDelete = itemsForDay[index]
            selectedTrip.destinations.removeAll(where: { $0.id == itemToDelete.id })
            modelContext.delete(itemToDelete)
        }
        reorderDestinations()
    }
    
    func moveDestination(from source: IndexSet, to destination: Int) {
        var itemsForDay = filteredDestinations
        itemsForDay.move(fromOffsets: source, toOffset: destination)
        
        for (index, item) in itemsForDay.enumerated() {
            item.visitOrder = index
        }
        saveContext()
    }
    
    func saveContext() {
        try? modelContext.save()
    }
    
    private func reorderDestinations() {
        let itemsForDay = filteredDestinations
        for (index, item) in itemsForDay.enumerated() {
            item.visitOrder = index
        }
        saveContext()
    }
    
    // MARK: - Search Logic (dipindahkan dari View)
    func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7424),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    return
                }
                
                guard let response = response else { return }
                
                self?.searchResults = response.mapItems.map { item in
                    LandmarkPlace(
                        name: item.name ?? "Unknown Place",
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude,
                        shortDesc: item.placemark.title ?? item.name ?? "Tempat ditemukan",
                        isUMKM: false
                    )
                }
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
    }
    
    // MARK: - Zoom Logic (dipindahkan dari View)
    func calculateZoomIn(currentDelta: Double) -> Double {
        return max(currentDelta * 0.5, 0.001)
    }
    
    func calculateZoomOut(currentDelta: Double) -> Double {
        return min(currentDelta * 2.0, 5.0)
    }
}
