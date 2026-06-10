//
// ItineraryCanvasXCTest.swift
// ALP_MADTests
//
// Created by student on 03/06/26.
//

import XCTest
import SwiftData
import CoreLocation
@testable import ALP_MAD

@MainActor
final class ItineraryCanvasXCTest: XCTestCase {
    
    var container: ModelContainer!
    var viewModel: ItineraryViewModel!
    var testTrip: Trip!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
        testTrip = Trip(title: "Test Trip", startDate: startDate, endDate: endDate)
        container.mainContext.insert(testTrip)
        try container.mainContext.save()
        
        viewModel = ItineraryViewModel(modelContext: container.mainContext, trip: testTrip)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        testTrip = nil
        container = nil
    }
    
    // MARK: - Destination Model Tests
    
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
        
        XCTAssertEqual(dest.name, "Tugu Pahlawan")
        XCTAssertEqual(dest.latitude, -7.2458)
        XCTAssertEqual(dest.longitude, 112.7378)
        XCTAssertFalse(dest.isLocalUMKM)
        XCTAssertEqual(dest.visitOrder, 0)
        XCTAssertEqual(dest.dayNumber, 1)
        XCTAssertEqual(dest.timeString, "09:00")
        XCTAssertEqual(dest.activityDesc, "Monumen bersejarah")
    }
    
    func testDestinationDefaultValues() throws {
        let dest = Destination(
            name: "Test Place",
            latitude: 0.0,
            longitude: 0.0
        )
        
        XCTAssertFalse(dest.isLocalUMKM)
        XCTAssertEqual(dest.visitOrder, 0)
        XCTAssertEqual(dest.dayNumber, 1)
        XCTAssertEqual(dest.timeString, "09:00")
        XCTAssertEqual(dest.activityDesc, "")
    }
    
    func testDestinationUMKMFlag() throws {
        let dest = Destination(
            name: "UMKM Place",
            latitude: -7.0,
            longitude: 112.0,
            isLocalUMKM: true
        )
        
        XCTAssertTrue(dest.isLocalUMKM)
    }
    
    func testDestinationCoordinate() throws {
        let dest = Destination(
            name: "Test",
            latitude: -7.25,
            longitude: 112.74
        )
        
        XCTAssertEqual(dest.coordinate.latitude, -7.25)
        XCTAssertEqual(dest.coordinate.longitude, 112.74)
    }
    
    // MARK: - LandmarkPlace Model Tests
    
    func testLandmarkPlaceInitialization() throws {
        let place = LandmarkPlace(
            name: "Test Place",
            latitude: -7.25,
            longitude: 112.74,
            shortDesc: "Description",
            isUMKM: false
        )
        
        XCTAssertEqual(place.name, "Test Place")
        XCTAssertEqual(place.latitude, -7.25)
        XCTAssertEqual(place.longitude, 112.74)
        XCTAssertEqual(place.shortDesc, "Description")
        XCTAssertFalse(place.isUMKM)
    }
    
    func testLandmarkPlaceCoordinate() throws {
        let place = LandmarkPlace(
            name: "Test",
            latitude: -7.25,
            longitude: 112.74,
            shortDesc: "Desc",
            isUMKM: false
        )
        
        XCTAssertEqual(place.coordinate.latitude, -7.25)
        XCTAssertEqual(place.coordinate.longitude, 112.74)
    }
    
    func testLandmarkPlaceEquality() throws {
        let id = UUID()
        let place1 = LandmarkPlace(
            id: id,
            name: "Place 1",
            latitude: -7.0,
            longitude: 112.0,
            shortDesc: "Desc 1",
            isUMKM: false
        )
        let place2 = LandmarkPlace(
            id: id,
            name: "Place 2",
            latitude: -8.0,
            longitude: 113.0,
            shortDesc: "Desc 2",
            isUMKM: true
        )
        
        XCTAssertEqual(place1, place2) // Same ID
    }
    
    func testLandmarkPlaceInequality() throws {
        let place1 = LandmarkPlace(
            name: "Place 1",
            latitude: -7.0,
            longitude: 112.0,
            shortDesc: "Desc",
            isUMKM: false
        )
        let place2 = LandmarkPlace(
            name: "Place 2",
            latitude: -7.0,
            longitude: 112.0,
            shortDesc: "Desc",
            isUMKM: false
        )
        
        XCTAssertNotEqual(place1, place2) // Different IDs
    }
    
    func testLandmarkPlaceUMKM() throws {
        let place = LandmarkPlace(
            name: "UMKM Place",
            latitude: -7.0,
            longitude: 112.0,
            shortDesc: "Desc",
            isUMKM: true
        )
        
        XCTAssertTrue(place.isUMKM)
    }
    
    // MARK: - ItineraryViewModel Initialization Tests
    
    func testViewModelInitialization() throws {
        XCTAssertEqual(viewModel.selectedDay, 1)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertNil(viewModel.timeConflictError)
        XCTAssertEqual(viewModel.currentZoomLevel, 0.05)
    }
    
    func testViewModelSelectedTrip() throws {
        XCTAssertEqual(viewModel.selectedTrip.id, testTrip.id)
        XCTAssertEqual(viewModel.selectedTrip.title, "Test Trip")
    }
    
    // MARK: - Filtered Destinations Tests
    
    func testFilteredDestinationsEmpty() throws {
        XCTAssertTrue(viewModel.filteredDestinations.isEmpty)
    }
    
    func testFilteredDestinationsByDay() throws {
        let dest1 = Destination(name: "Day 1 Place", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "09:00")
        let dest2 = Destination(name: "Day 2 Place", latitude: -7.0, longitude: 112.0, dayNumber: 2, timeString: "10:00")
        
        testTrip.destinations.append(dest1)
        testTrip.destinations.append(dest2)
        
        viewModel.selectedDay = 1
        XCTAssertEqual(viewModel.filteredDestinations.count, 1)
        XCTAssertEqual(viewModel.filteredDestinations.first?.name, "Day 1 Place")
        
        viewModel.selectedDay = 2
        XCTAssertEqual(viewModel.filteredDestinations.count, 1)
        XCTAssertEqual(viewModel.filteredDestinations.first?.name, "Day 2 Place")
    }
    
    func testFilteredDestinationsSortedByTime() throws {
        let dest1 = Destination(name: "Morning", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "09:00")
        let dest2 = Destination(name: "Afternoon", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "14:00")
        let dest3 = Destination(name: "Noon", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "12:00")
        
        testTrip.destinations.append(dest1)
        testTrip.destinations.append(dest2)
        testTrip.destinations.append(dest3)
        
        let filtered = viewModel.filteredDestinations
        XCTAssertEqual(filtered.count, 3)
        XCTAssertEqual(filtered[0].timeString, "09:00")
        XCTAssertEqual(filtered[1].timeString, "12:00")
        XCTAssertEqual(filtered[2].timeString, "14:00")
    }
    
    func testFilteredDestinationsMultipleDays() throws {
        let dest1 = Destination(name: "Day 1 Morning", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "09:00")
        let dest2 = Destination(name: "Day 1 Afternoon", latitude: -7.0, longitude: 112.0, dayNumber: 1, timeString: "14:00")
        let dest3 = Destination(name: "Day 2 Morning", latitude: -7.0, longitude: 112.0, dayNumber: 2, timeString: "09:00")
        
        testTrip.destinations.append(dest1)
        testTrip.destinations.append(dest2)
        testTrip.destinations.append(dest3)
        
        viewModel.selectedDay = 1
        XCTAssertEqual(viewModel.filteredDestinations.count, 2)
        
        viewModel.selectedDay = 2
        XCTAssertEqual(viewModel.filteredDestinations.count, 1)
    }
    
    // MARK: - Add Destination Tests
    
    func testAddDestinationWithTimeSuccess() throws {
        let place = LandmarkPlace(
            name: "New Place",
            latitude: -7.25,
            longitude: 112.74,
            shortDesc: "Description",
            isUMKM: false
        )
        
        let result = viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        XCTAssertTrue(result.success)
        XCTAssertNil(result.message)
        XCTAssertEqual(viewModel.filteredDestinations.count, 1)
        XCTAssertEqual(viewModel.filteredDestinations.first?.name, "New Place")
        XCTAssertEqual(viewModel.filteredDestinations.first?.timeString, "10:00")
    }
    
    func testAddDestinationWithTimeConflict() throws {
        let place1 = LandmarkPlace(name: "Place 1", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Place 2", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        let result1 = viewModel.addDestinationWithTime(place: place1, timeString: "10:00")
        XCTAssertTrue(result1.success)
        
        let result2 = viewModel.addDestinationWithTime(place: place2, timeString: "10:00")
        XCTAssertFalse(result2.success)
        XCTAssertNotNil(result2.message)
        XCTAssertNotNil(viewModel.timeConflictError)
    }
    
    func testAddDestinationSetsCorrectDayNumber() throws {
        viewModel.selectedDay = 2
        let place = LandmarkPlace(name: "Place", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        XCTAssertEqual(viewModel.filteredDestinations.first?.dayNumber, 2)
    }
    
    func testAddDestinationSetsCoordinates() throws {
        let place = LandmarkPlace(
            name: "Place",
            latitude: -7.25,
            longitude: 112.74,
            shortDesc: "Desc",
            isUMKM: false
        )
        
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        XCTAssertEqual(viewModel.filteredDestinations.first?.latitude, -7.25)
        XCTAssertEqual(viewModel.filteredDestinations.first?.longitude, 112.74)
    }
    
    func testAddDestinationSetsUMKMFlag() throws {
        let place = LandmarkPlace(
            name: "UMKM",
            latitude: -7.0,
            longitude: 112.0,
            shortDesc: "Desc",
            isUMKM: true
        )
        
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        XCTAssertTrue(viewModel.filteredDestinations.first?.isLocalUMKM ?? false)
    }
    
    // MARK: - Update Destination Time Tests
    
    func testUpdateDestinationTimeSuccess() throws {
        let place = LandmarkPlace(name: "Place", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        let dest = viewModel.filteredDestinations.first!
        let result = viewModel.updateDestinationTime(destination: dest, newTimeString: "11:00")
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(dest.timeString, "11:00")
    }
    
    func testUpdateDestinationTimeConflict() throws {
        let place1 = LandmarkPlace(name: "Place 1", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Place 2", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "10:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "11:00")
        
        let dest2 = viewModel.filteredDestinations.first { $0.name == "Place 2" }!
        let result = viewModel.updateDestinationTime(destination: dest2, newTimeString: "10:00")
        
        XCTAssertFalse(result.success)
        XCTAssertNotNil(viewModel.timeConflictError)
    }
    
    func testUpdateDestinationTimeSameTimeAllowed() throws {
        let place = LandmarkPlace(name: "Place", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        let dest = viewModel.filteredDestinations.first!
        let result = viewModel.updateDestinationTime(destination: dest, newTimeString: "10:00")
        
        XCTAssertTrue(result.success) // Should allow updating to same time
    }
    
    // MARK: - Visit Order Tests
    
    func testRecalculateVisitOrder() throws {
        let place1 = LandmarkPlace(name: "First", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Second", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place3 = LandmarkPlace(name: "Third", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "14:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "09:00")
        viewModel.addDestinationWithTime(place: place3, timeString: "12:00")
        
        let filtered = viewModel.filteredDestinations
        XCTAssertEqual(filtered[0].visitOrder, 0) // 09:00
        XCTAssertEqual(filtered[1].visitOrder, 1) // 12:00
        XCTAssertEqual(filtered[2].visitOrder, 2) // 14:00
    }
    
    func testRecalculateVisitOrderAfterUpdate() throws {
        let place1 = LandmarkPlace(name: "First", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Second", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "09:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "10:00")
        
        let dest1 = viewModel.filteredDestinations.first { $0.name == "First" }!
        viewModel.updateDestinationTime(destination: dest1, newTimeString: "11:00")
        
        let filtered = viewModel.filteredDestinations
        XCTAssertEqual(filtered[0].name, "Second") // Now first
        XCTAssertEqual(filtered[1].name, "First") // Now second
        XCTAssertEqual(filtered[0].visitOrder, 0)
        XCTAssertEqual(filtered[1].visitOrder, 1)
    }
    
    // MARK: - Delete Destination Tests
    
    func testDeleteDestinationById() throws {
        let place = LandmarkPlace(name: "To Delete", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        let dest = viewModel.filteredDestinations.first!
        viewModel.deleteDestinationById(dest.id)
        
        XCTAssertTrue(viewModel.filteredDestinations.isEmpty)
    }
    
    func testDeleteDestinationRecalculatesOrder() throws {
        let place1 = LandmarkPlace(name: "First", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Second", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place3 = LandmarkPlace(name: "Third", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "09:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "10:00")
        viewModel.addDestinationWithTime(place: place3, timeString: "11:00")
        
        let dest2 = viewModel.filteredDestinations.first { $0.name == "Second" }!
        viewModel.deleteDestinationById(dest2.id)
        
        let filtered = viewModel.filteredDestinations
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered[0].visitOrder, 0)
        XCTAssertEqual(filtered[1].visitOrder, 1)
    }
    
    func testDeleteDestinationAtOffsets() throws {
        let place1 = LandmarkPlace(name: "First", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        let place2 = LandmarkPlace(name: "Second", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        
        viewModel.addDestinationWithTime(place: place1, timeString: "09:00")
        viewModel.addDestinationWithTime(place: place2, timeString: "10:00")
        
        viewModel.deleteDestination(at: IndexSet(integer: 0))
        
        XCTAssertEqual(viewModel.filteredDestinations.count, 1)
        XCTAssertEqual(viewModel.filteredDestinations.first?.name, "Second")
    }
    
    // MARK: - Search Tests
    
    func testClearSearch() throws {
        viewModel.searchText = "test"
        viewModel.searchResults = [LandmarkPlace(name: "Result", latitude: 0, longitude: 0, shortDesc: "Desc", isUMKM: false)]
        viewModel.timeConflictError = "Error"
        
        viewModel.clearSearch()
        
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertNil(viewModel.timeConflictError)
    }
    
    func testSearchTextProperty() throws {
        viewModel.searchText = "Hotel"
        XCTAssertEqual(viewModel.searchText, "Hotel")
    }
    
    // MARK: - Zoom Tests
    
    func testCalculateZoomIn() throws {
        let result = viewModel.calculateZoomIn(currentDelta: 0.1)
        XCTAssertEqual(result, 0.05, accuracy: 0.0001)
    }
    
    func testCalculateZoomInMinimum() throws {
        let result = viewModel.calculateZoomIn(currentDelta: 0.0001)
        XCTAssertEqual(result, 0.0001, accuracy: 0.00001)
    }
    
    func testCalculateZoomOut() throws {
        let result = viewModel.calculateZoomOut(currentDelta: 0.1)
        XCTAssertEqual(result, 0.2, accuracy: 0.0001)
    }
    
    func testCalculateZoomOutMaximum() throws {
        let result = viewModel.calculateZoomOut(currentDelta: 30.0)
        XCTAssertEqual(result, 50.0, accuracy: 0.0001)
    }
    
    // MARK: - Discoverable Places Tests
    
    func testDiscoverablePlacesNotEmpty() throws {
        XCTAssertFalse(viewModel.discoverablePlaces.isEmpty)
        XCTAssertEqual(viewModel.discoverablePlaces.count, 3)
    }
    
    func testDiscoverablePlacesContainsUMKM() throws {
        let umkmPlaces = viewModel.discoverablePlaces.filter { $0.isUMKM }
        XCTAssertFalse(umkmPlaces.isEmpty)
    }
    
    // MARK: - Save Context Tests
    
    func testSaveContext() throws {
        let place = LandmarkPlace(name: "Place", latitude: -7.0, longitude: 112.0, shortDesc: "Desc", isUMKM: false)
        viewModel.addDestinationWithTime(place: place, timeString: "10:00")
        
        // Should not throw
        viewModel.saveContext()
        
        // Verify data was saved
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrip = try container.mainContext.fetch(descriptor).first
        XCTAssertNotNil(fetchedTrip)
        XCTAssertEqual(fetchedTrip?.destinations.count, 1)
    }
}
