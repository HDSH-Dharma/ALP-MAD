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
}

// Struktur Data untuk Pin Interaktif di Peta
struct LandmarkPlace: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let shortDesc: String
    let isUMKM: Bool
}
