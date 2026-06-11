//
// ItineraryCanvasSwiftTesting.swift
// ALP_MADTests
//
// Created by student on 03/06/26.
//

import Testing
import SwiftData
import CoreLocation
@testable import ALP_MAD

@Suite("Itinerary Canvas Swift Testing", .serialized)
struct ItineraryCanvasSwiftTesting {
    
    // MARK: - Helper Functions
    
    @MainActor
    private func createTestEnvironment() throws -> ModelContainer {
        let container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return container
    }

    @MainActor
    private func createTestTrip(in container: ModelContainer) throws -> Trip {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
        let trip = Trip(title: "Test Trip", startDate: startDate, endDate: endDate)
        container.mainContext.insert(trip)
        try container.mainContext.save()
        return trip
    }
    
    // MARK: - Destination Model Tests
    
    @Test("Destination initialization with all properties")
    func testDestinationInitialization() throws {
        let dest = Destination(
            name: "Tugu Pahlawan",
            latitude: -7.2458,
            longitude: 112.7378,
            isLocalUMKM: false,
            visitOrder: 0,
            dayNumber: 1,
            timeString: "09:00",
            activityDesc: "Monumen bersejarah"
        )
        
        #expect(dest.name == "Tugu Pahlawan")
        #expect(dest.latitude == -7.2458)
        #expect(dest.longitude == 112.7378)
        #expect(dest.isLocalUMKM == false)
        #expect(dest.visitOrder == 0)
        #expect(dest.dayNumber == 1)
        #expect(dest.timeString == "09:00")
        #expect(dest.activityDesc == "Monumen bersejarah")
    }
    
    @Test("Destination default values")
    func testDestinationDefaultValues() throws {
        let dest = Destination(name: "Test", latitude: 0.0, longitude: 0.0)
        
        #expect(dest.isLocalUMKM == false)
        #expect(dest.visitOrder == 0)
        #expect(dest.dayNumber == 1)
        #expect(dest.timeString == "09:00")
        #expect(dest.activityDesc == "")
    }
    
    @Test("Destination UMKM flag")
    func testDestinationUMKMFlag() throws {
        let dest = Destination(name: "UMKM", latitude: -7.0, longitude: 112.0, isLocalUMKM: true)
        #expect(dest.isLocalUMKM == true)
    }
    
    @Test("Destination coordinate property")
    func testDestinationCoordinate() throws {
        let dest = Destination(name: "Test", latitude: -7.25, longitude: 112.74)
        #expect(dest.coordinate.latitude == -7.25)
        #expect(dest.coordinate.longitude == 112.74)
    }
    
    // MARK: - LandmarkPlace Model Tests
    
    @Test("LandmarkPlace initialization")
    func testLandmarkPlaceInitialization() throws {
        let place = LandmarkPlace(
            name: "Test Place",
            latitude: -7.25,
            longitude: 112.74,
            shortDesc: "Description",
            isUMKM: false
        )
        
        #expect(place.name == "Test Place")
        #expect(place.latitude == -7.25)
        #expect(place.longitude == 112.74)
        #expect(place.shortDesc == "Description")
        #expect(place.isUMKM == false)
    }
    
    @Test("LandmarkPlace coordinate property")
    func testLandmarkPlaceCoordinate() throws {
        let place = LandmarkPlace(name: "Test", latitude: -7.25, longitude: 112.74, shortDesc: "Desc", isUMKM: false)
        
        #expect(place.coordinate.latitude == -7.25)
        #expect(place.coordinate.longitude == 112.74)
    }
    
    @Test("LandmarkPlace equality with same ID")
    func testLandmarkPlaceEquality() throws {
        let id = UUID()
        let place1 = LandmarkPlace(id: id, name: "Place 1", latitude: -7.0, longitude: 112.0, shortDesc: "Desc 1", isUMKM: false)
        let place2 = LandmarkPlace(id: id, name: "Place 2", latitude: -8.0, longitude: 113.0, shortDesc: "Desc 2", isUMKM: true)
        
        #expect(place1 == place2)
    }
    
    @Test("LandmarkPlace inequality with different IDs")
    func testLandmarkPlaceInequality() throws {
        let place1 = LandmarkPlace(name: "Place 1", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Place 2", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        #expect(place1 != place2)
    }
    
    @Test("LandmarkPlace UMKM flag")
    func testLandmarkPlaceUMKM() throws {
        let place = LandmarkPlace(name: "UMKM", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: true)
        #expect(place.isUMKM == true)
    }
    
    // MARK: - ViewModel Initialization Tests
    
    @Test("ViewModel initialization")
    @MainActor
    func testViewModelInitialization() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        
        #expect(viewModel.selectedDay == 1)
        #expect(viewModel.searchText == "")
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isSearching == false)
        #expect(viewModel.timeConflictError == nil)
        #expect(viewModel.currentZoomLevel == 0.05)
    }
    
    @Test("ViewModel selected trip")
    @MainActor
    func testViewModelSelectedTrip() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        #expect(viewModel.selectedTrip.id == trip.id)
        #expect(viewModel.selectedTrip.title == "Test Trip")
    }
    
    // MARK: - Filtered Destinations Tests
    
    @Test("Filtered destinations empty initially")
    @MainActor
    func testFilteredDestinationsEmpty() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        #expect(viewModel.filteredDestinations.isEmpty)
    }
    
    @Test("Filtered destinations by day")
    @MainActor
    func testFilteredDestinationsByDay() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        
        let dest1 = Destination(name: "Day 1", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "09:00")
        let dest2 = Destination(name: "Day 2", latitude: -7.0, longitude: 112.0, dayNumber: 2, timeString: "10:00")
        
        trip.destinations.append(dest1)
        trip.destinations.append(dest2)
        
        viewModel.selectedDay = 1
        #expect(viewModel.filteredDestinations.count == 1)
        #expect(viewModel.filteredDestinations.first?.name == "Day 1")
        
        viewModel.selectedDay = 2
        #expect(viewModel.filteredDestinations.count == 1)
        #expect(viewModel.filteredDestinations.first?.name == "Day 2")
    }
    
    @Test("Filtered destinations sorted by time")
    @MainActor
    func testFilteredDestinationsSortedByTime() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        
        let dest1 = Destination(name: "Morning", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "09:00")
        let dest2 = Destination(name: "Afternoon", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "14:00")
        let dest3 = Destination(name: "Noon", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "12:00")
        
        trip.destinations.append(dest1)
        trip.destinations.append(dest2)
        trip.destinations.append(dest3)
        
        let filtered = viewModel.filteredDestinations
        #expect(filtered.count == 3)
        #expect(filtered[0].timeString == "09:00")
        #expect(filtered[1].timeString == "12:00")
        #expect(filtered[2].timeString == "14:00")
    }
    
    @Test("Filtered destinations multiple days")
    @MainActor
    func testFilteredDestinationsMultipleDays() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        
        let dest1 = Destination(name: "Day 1 Morning", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "09:00")
        let dest2 = Destination(name: "Day 1 Afternoon", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "14:00")
        let dest3 = Destination(name: "Day 2 Morning", latitude: -7.0, longitude: 112.0, dayNumber: 2, timeString: "09:00")
        
        trip.destinations.append(dest1)
        trip.destinations.append(dest2)
        trip.destinations.append(dest3)
        
        viewModel.selectedDay = 1
        #expect(viewModel.filteredDestinations.count == 2)
        
        viewModel.selectedDay = 2
        #expect(viewModel.filteredDestinations.count == 1)
    }
    
    // MARK: - Add Destination Tests
    
    @Test("Add destination with time success")
    @MainActor
    func testAddDestinationWithTimeSuccess() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place = LandmarkPlace(name: "New Place", latitude: -7.25, longitude: 112.74, shortDesc: "Desc", isUMKM: false)
        
        let result = viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        #expect(result.success == true)
        #expect(result.message == nil)
        #expect(viewModel.filteredDestinations.count == 1)
        #expect(viewModel.filteredDestinations.first?.name == "New Place")
        #expect(viewModel.filteredDestinations.first?.timeString == "10:00")
    }
    
    @Test("Add destination with time conflict")
    @MainActor
    func testAddDestinationWithTimeConflict() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place1 = LandmarkPlace(name: "Place 1", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Place 2", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        let result1 = viewModel.addDestinationWithTime(place: place1, timeString: "10:00")
        #expect(result1.success == true)
        
        let result2 = viewModel.addDestinationWithTime(place: place2, timeString: "10:00")
        #expect(result2.success == false)
        #expect(result2.message != nil)
        #expect(viewModel.timeConflictError != nil)
    }
    
    @Test("Add destination sets correct day number")
    @MainActor
    func testAddDestinationSetsCorrectDayNumber() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        viewModel.selectedDay = 2
        let place = LandmarkPlace(name: "Place", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        #expect(viewModel.filteredDestinations.first?.dayNumber == 2)
    }
    
    @Test("Add destination sets coordinates")
    @MainActor
    func testAddDestinationSetsCoordinates() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place = LandmarkPlace(name: "Place", latitude: -7.25, longitude: 112.74, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        #expect(viewModel.filteredDestinations.first?.latitude == -7.25)
        #expect(viewModel.filteredDestinations.first?.longitude == 112.74)
    }
    
    @Test("Add destination sets UMKM flag")
    @MainActor
    func testAddDestinationSetsUMKMFlag() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place = LandmarkPlace(name: "UMKM", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: true)
        
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        #expect(viewModel.filteredDestinations.first?.isLocalUMKM == true)
    }
    
    // MARK: - Update Destination Time Tests
    
    @Test("Update destination time success")
    @MainActor
    func testUpdateDestinationTimeSuccess() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place = LandmarkPlace(name: "Place", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        let dest = viewModel.filteredDestinations.first!
        let result = viewModel.updateDestinationTime(destination: dest, newTimeString: "11:00")
        
        #expect(result.success == true)
        #expect(dest.timeString == "11:00")
    }
    
    @Test("Update destination time conflict")
    @MainActor
    func testUpdateDestinationTimeConflict() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place1 = LandmarkPlace(name: "Place 1", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Place 2", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "10:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "11:00")
        
        let dest2 = viewModel.filteredDestinations.first { $0.name == "Place 2" }!
        let result = viewModel.updateDestinationTime(destination: dest2, newTimeString: "10:00")
        
        #expect(result.success == false)
        #expect(viewModel.timeConflictError != nil)
    }
    
    @Test("Update destination time same time allowed")
    @MainActor
    func testUpdateDestinationTimeSameTimeAllowed() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place = LandmarkPlace(name: "Place", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        let dest = viewModel.filteredDestinations.first!
        let result = viewModel.updateDestinationTime(destination: dest, newTimeString: "10:00")
        
        #expect(result.success == true)
    }
    
    // MARK: - Visit Order Tests
    
    @Test("Recalculate visit order based on time")
    @MainActor
    func testRecalculateVisitOrder() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place1 = LandmarkPlace(name: "First", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Second", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place3 = LandmarkPlace(name: "Third", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "14:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "09:00")
        viewModel.addDestinationWithTime(place: place3, timeString: "12:00")
        
        let filtered = viewModel.filteredDestinations
        #expect(filtered[0].visitOrder == 0) // 09:00
        #expect(filtered[1].visitOrder == 1) // 12:00
        #expect(filtered[2].visitOrder == 2) // 14:00
    }
    
    @Test("Recalculate visit order after update")
    @MainActor
    func testRecalculateVisitOrderAfterUpdate() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place1 = LandmarkPlace(name: "First", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Second", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "09:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "10:00")
        
        let dest1 = viewModel.filteredDestinations.first { $0.name == "First" }!
        viewModel.updateDestinationTime(destination: dest1, newTimeString: "11:00")
        
        let filtered = viewModel.filteredDestinations
        #expect(filtered[0].name == "Second")
        #expect(filtered[1].name == "First")
        #expect(filtered[0].visitOrder == 0)
        #expect(filtered[1].visitOrder == 1)
    }
    
    // MARK: - Delete Destination Tests
    
    @Test("Delete destination by ID")
    @MainActor
    func testDeleteDestinationById() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place = LandmarkPlace(name: "To Delete", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        let dest = viewModel.filteredDestinations.first!
        viewModel.deleteDestinationById(dest.id)
        
        #expect(viewModel.filteredDestinations.isEmpty)
    }
    
    @Test("Delete destination recalculates order")
    @MainActor
    func testDeleteDestinationRecalculatesOrder() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let place1 = LandmarkPlace(name: "First", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Second", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place3 = LandmarkPlace(name: "Third", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "09:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "10:00")
        viewModel.addDestinationWithTime(place: place3, timeString: "11:00")
        
        let dest2 = viewModel.filteredDestinations.first { $0.name == "Second" }!
        viewModel.deleteDestinationById(dest2.id)
        
        let filtered = viewModel.filteredDestinations
        #expect(filtered.count == 2)
        #expect(filtered[0].visitOrder == 0)
        #expect(filtered[1].visitOrder == 1)
    }
    
    // MARK: - Search Tests
    
    @Test("Clear search resets all search state")
    @MainActor
    func testClearSearch() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        viewModel.searchText = "test"
        viewModel.searchResults = [LandmarkPlace(name: "Result", latitude: 0, longitude: 0, shortDesc: "Desc", isUMKM: false)]
        viewModel.timeConflictError = "Error"
        
        viewModel.clearSearch()
        
        #expect(viewModel.searchText == "")
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.timeConflictError == nil)
    }
    
    @Test("Search text property")
    @MainActor
    func testSearchTextProperty() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        viewModel.searchText = "Hotel"
        #expect(viewModel.searchText == "Hotel")
    }
    
    // MARK: - Zoom Tests
    
    @Test("Calculate zoom in")
    @MainActor
    func testCalculateZoomIn() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        
        let result = viewModel.calculateZoomIn(currentDelta: 0.1)
        #expect(abs(result - 0.05) < 0.0001)
    }
    
    @Test("Calculate zoom in minimum")
    @MainActor
    func testCalculateZoomInMinimum() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        
        let result = viewModel.calculateZoomIn(currentDelta: 0.0001)
        #expect(abs(result - 0.0001) < 0.00001)
    }
    
    @Test("Calculate zoom out")
    @MainActor
    func testCalculateZoomOut() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        
        let result = viewModel.calculateZoomOut(currentDelta: 0.1)
        #expect(abs(result - 0.2) < 0.0001)
    }
    
    @Test("Calculate zoom out maximum")
    @MainActor
    func testCalculateZoomOutMaximum() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        
        let result = viewModel.calculateZoomOut(currentDelta: 30.0)
        #expect(abs(result - 50.0) < 0.0001)
    }
    
    // MARK: - Discoverable Places Tests
    
    @Test("Discoverable places not empty")
    @MainActor
    func testDiscoverablePlacesNotEmpty() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        #expect(viewModel.discoverablePlaces.isEmpty == false)
        #expect(viewModel.discoverablePlaces.count == 3)
    }
    
    @Test("Discoverable places contains UMKM")
    @MainActor
    func testDiscoverablePlacesContainsUMKM() async throws {
        let container = try createTestEnvironment()
        let trip = try createTestTrip(in: container)
        let viewModel = ItineraryViewModel(
            modelContext: container.mainContext,
            trip: trip
        )
        let umkmPlaces = viewModel.discoverablePlaces.filter { $0.isUMKM }
        #expect(umkmPlaces.isEmpty == false)
    }
}
