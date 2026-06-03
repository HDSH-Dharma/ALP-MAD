//
//  ItineraryCanvasXCTest.swift
//  ALP_MADTests
//
//  Created by student on 03/06/26.
//

import SwiftUI
import XCTest
import SwiftData
@testable import ALP_MAD

@MainActor
final class ItineraryCanvasXCTest: XCTestCase {
    
    var container: ModelContainer!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
    
    override func tearDownWithError() throws {
        container = nil
    }
    
    // MARK: - Trip Model Tests
    
    func testTripInitialization() throws {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
        let trip = Trip(name: "Bali Trip", destination: "Bali", startDate: startDate, endDate: endDate)
        
        XCTAssertEqual(trip.name, "Bali Trip")
        XCTAssertEqual(trip.destination, "Bali")
        XCTAssertEqual(trip.startDate, startDate)
        XCTAssertEqual(trip.endDate, endDate)
        XCTAssertTrue(trip.destinations.isEmpty)
    }
    
    func testTripTotalDaysCalculation() throws {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 2, to: startDate)!
        
        let trip = Trip(name: "Test Trip", destination: "Test City", startDate: startDate, endDate: endDate)
        
        XCTAssertEqual(trip.totalDays, 3)
    }
    
    func testTripTotalDaysSameDate() throws {
        let sameDay = Date()
        let trip = Trip(name: "One Day Trip", destination: "Test City", startDate: sameDay, endDate: sameDay)
        
        XCTAssertEqual(trip.totalDays, 1)
    }
    
    func testTripDateRangeValidation() throws {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 5)
        
        let trip = Trip(name: "Five Day Trip", destination: "Test City", startDate: startDate, endDate: endDate)
        
        XCTAssertEqual(trip.totalDays, 6)
        XCTAssertTrue(trip.endDate > trip.startDate)
    }
    
    // MARK: - SwiftData Persistence Tests
    
    func testSaveAndFetchTrip() throws {
        let context = container.mainContext
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate)!
        let trip = Trip(name: "Surabaya Trip", destination: "Surabaya", startDate: startDate, endDate: endDate)
        
        context.insert(trip)
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrips = try context.fetch(descriptor)
        
        XCTAssertEqual(fetchedTrips.count, 1)
        XCTAssertEqual(fetchedTrips.first?.name, "Surabaya Trip")
    }
    
    func testUpdateTripProperties() throws {
        let context = container.mainContext
        
        let trip = Trip(name: "Original Title", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        trip.name = "Updated Title"
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrip = try context.fetch(descriptor).first
        
        XCTAssertEqual(fetchedTrip?.name, "Updated Title")
    }
    
    func testMultipleTrips() throws {
        let context = container.mainContext
        
        let trip1 = Trip(name: "Trip 1", destination: "City A", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let trip2 = Trip(name: "Trip 2", destination: "City B", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 2))
        let trip3 = Trip(name: "Trip 3", destination: "City C", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 3))
        
        context.insert(trip1)
        context.insert(trip2)
        context.insert(trip3)
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(descriptor)
        
        XCTAssertEqual(trips.count, 3)
        
        let names = trips.map { $0.name }.sorted()
        XCTAssertEqual(names, ["Trip 1", "Trip 2", "Trip 3"])
    }
    
    func testDeleteTrip() throws {
        let context = container.mainContext
        
        let trip = Trip(name: "To Delete", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        context.delete(trip)
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(descriptor)
        
        XCTAssertTrue(trips.isEmpty)
    }
    
    func testFetchTripWithSort() throws {
        let context = container.mainContext
        
        let tripC = Trip(name: "C Trip", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let tripA = Trip(name: "A Trip", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let tripB = Trip(name: "B Trip", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        context.insert(tripC)
        context.insert(tripA)
        context.insert(tripB)
        try context.save()
        
        var descriptor = FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.name)])
        let sortedTrips = try context.fetch(descriptor)
        
        XCTAssertEqual(sortedTrips.count, 3)
        XCTAssertEqual(sortedTrips[0].name, "A Trip")
        XCTAssertEqual(sortedTrips[1].name, "B Trip")
        XCTAssertEqual(sortedTrips[2].name, "C Trip")
    }
    
    func testTripEmptyDestinations() throws {
        let context = container.mainContext
        
        let trip = Trip(name: "Empty Trip", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        XCTAssertTrue(trip.destinations.isEmpty)
    }
    
    func testUpdateTripStartDate() throws {
        let context = container.mainContext
        
        let originalDate = Date()
        let trip = Trip(name: "Date Update Trip", destination: "Test City", startDate: originalDate, endDate: originalDate.addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        let newDate = originalDate.addingTimeInterval(86400 * 2)
        trip.startDate = newDate
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetched = try context.fetch(descriptor).first
        
        XCTAssertEqual(fetched?.startDate, newDate)
    }
    
    func testFetchTripWithPredicate() throws {
        let context = container.mainContext
        
        let trip1 = Trip(name: "Bali Trip", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let trip2 = Trip(name: "Java Trip", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let trip3 = Trip(name: "Bali Holiday", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        context.insert(trip1)
        context.insert(trip2)
        context.insert(trip3)
        try context.save()
        
        let predicate = #Predicate<Trip> { $0.name.contains("Bali") }
        var descriptor = FetchDescriptor<Trip>(predicate: predicate)
        let results = try context.fetch(descriptor)
        
        XCTAssertEqual(results.count, 2)
    }
    
    func testTripTotalDaysTenDayTrip() throws {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 9, to: startDate)!
        let trip = Trip(name: "Ten Day Trip", destination: "Test City", startDate: startDate, endDate: endDate)
        
        XCTAssertEqual(trip.totalDays, 10)
    }
    
    func testMultipleSaveAndFetchCycle() throws {
        let context = container.mainContext
        
        // Cycle 1: Insert
        let trip1 = Trip(name: "First", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip1)
        try context.save()
        
        var descriptor = FetchDescriptor<Trip>()
        XCTAssertEqual(try context.fetch(descriptor).count, 1)
        
        // Cycle 2: Insert again
        let trip2 = Trip(name: "Second", destination: "Test City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip2)
        try context.save()
        
        XCTAssertEqual(try context.fetch(descriptor).count, 2)
        
        // Cycle 3: Delete one
        context.delete(trip1)
        try context.save()
        
        XCTAssertEqual(try context.fetch(descriptor).count, 1)
        XCTAssertEqual(try context.fetch(descriptor).first?.name, "Second")
    }
}
