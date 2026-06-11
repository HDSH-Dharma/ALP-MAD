//
// ItineraryViewModel.swift
// ALP_MAD
//
// Created by student on 28/05/26.
//

import Foundation
import SwiftData
import MapKit
import SwiftUI
import Combine

final class ItineraryViewModel: ObservableObject {
    var modelContext: ModelContext
    var selectedTrip: Trip
    @Published var selectedDay: Int = 1
        
    // MARK: - Search State
    @Published var searchText: String = ""
    @Published var searchResults: [LandmarkPlace] = []
    @Published var isSearching: Bool = false
    
    // MARK: - Time Conflict Error
    @Published var timeConflictError: String? = nil
    
    // MARK: - Discoverable Places
    var discoverablePlaces: [LandmarkPlace] = [
        LandmarkPlace(name: "Tugu Pahlawan", latitude: -7.2458, longitude: 112.7378, shortDesc: "Monumen bersejarah perjuangan pahlawan.", isUMKM: false),
        LandmarkPlace(name: "Sentra Kuliner GWalk", latitude: -7.2891, longitude: 112.6415, shortDesc: "Pusat UMKM Kuliner warga lokal dengan cita rasa autentik.", isUMKM: true),
        LandmarkPlace(name: "Pasar Seni Lokal", latitude: -7.2531, longitude: 112.7401, shortDesc: "Oleh-oleh kerajinan tangan asli Suroboyo.", isUMKM: true)
    ]
    
    // MARK: - Zoom State
    @Published var currentZoomLevel: Double = 0.05
    
    init(modelContext: ModelContext, trip: Trip) {
        self.modelContext = modelContext
        self.selectedTrip = trip
    }
    
    // Filter destinasi hanya untuk hari yang dipilih, sorted by time
    var filteredDestinations: [Destination] {
        selectedTrip.destinations
            .filter { $0.dayNumber == selectedDay }
            .sorted { $0.timeString < $1.timeString }
    }
    
    // MARK: - Add Destination with Time
    struct AddResult {
        let success: Bool
        let message: String?
    }
    
    func addDestinationWithTime(place: LandmarkPlace, timeString: String) -> AddResult {
        // Check for time conflict
        if hasTimeConflict(timeString: timeString, excludeId: nil) {
            timeConflictError = "Jam \(timeString) sudah digunakan oleh tempat lain. Silakan pilih jam berbeda."
            return AddResult(success: false, message: timeConflictError)
        }
        
        timeConflictError = nil
        
        let newDest = Destination(
            name: place.name,
            latitude: place.latitude,
            longitude: place.longitude,
            isLocalUMKM: place.isUMKM,
            visitOrder: 0, // Will be recalculated
            dayNumber: selectedDay,
            timeString: timeString,
            activityDesc: place.shortDesc
        )
        selectedTrip.destinations.append(newDest)
        
        // Recalculate visit order based on time
        recalculateVisitOrder()
        saveContext()
        
        return AddResult(success: true, message: nil)
    }
    
    // MARK: - Update Destination Time
    func updateDestinationTime(destination: Destination, newTimeString: String) -> AddResult {
        // Check for time conflict (exclude current destination)
        if hasTimeConflict(timeString: newTimeString, excludeId: destination.id) {
            timeConflictError = "Jam \(newTimeString) sudah digunakan oleh tempat lain. Silakan pilih jam berbeda."
            return AddResult(success: false, message: timeConflictError)
        }
        
        timeConflictError = nil
        destination.timeString = newTimeString
        
        // Recalculate visit order based on time
        recalculateVisitOrder()
        saveContext()
        
        return AddResult(success: true, message: nil)
    }
    
    // MARK: - Check Time Conflict
    private func hasTimeConflict(timeString: String, excludeId: UUID?) -> Bool {
        let destinationsForDay = selectedTrip.destinations.filter { $0.dayNumber == selectedDay }
        
        for dest in destinationsForDay {
            if excludeId != nil && dest.id == excludeId! {
                continue
            }
            if dest.timeString == timeString {
                return true
            }
        }
        return false
    }
    
    // MARK: - Recalculate Visit Order
    private func recalculateVisitOrder() {
        let sortedDestinations = selectedTrip.destinations
            .filter { $0.dayNumber == selectedDay }
            .sorted { $0.timeString < $1.timeString }
        
        for (index, dest) in sortedDestinations.enumerated() {
            dest.visitOrder = index
        }
    }
    
    // MARK: - Delete Destination
    func deleteDestination(at offsets: IndexSet) {
        let itemsForDay = filteredDestinations
        for index in offsets {
            let itemToDelete = itemsForDay[index]
            selectedTrip.destinations.removeAll(where: { $0.id == itemToDelete.id })
            modelContext.delete(itemToDelete)
        }
        recalculateVisitOrder()
        saveContext()
    }
    
    func deleteDestinationById(_ id: UUID) {
        if let dest = selectedTrip.destinations.first(where: { $0.id == id }) {
            selectedTrip.destinations.removeAll(where: { $0.id == id })
            modelContext.delete(dest)
            recalculateVisitOrder()
            saveContext()
        }
    }
    
    func saveContext() {
        try? modelContext.save()
    }
    
    // MARK: - Search Logic
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
        timeConflictError = nil
    }
    
    // MARK: - Zoom Logic
    func calculateZoomIn(currentDelta: Double) -> Double {
        return max(currentDelta * 0.5, 0.0001)
    }
    
    func calculateZoomOut(currentDelta: Double) -> Double {
        return min(currentDelta * 2.0, 50.0)
    }
}
