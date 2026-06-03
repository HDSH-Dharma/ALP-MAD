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
        let trip = Trip(title: "Bali Trip", startDate: startDate, endDate: endDate)
        
        XCTAssertEqual(trip.title, "Bali Trip")
        XCTAssertEqual(trip.startDate, startDate)
        XCTAssertEqual(trip.endDate, endDate)
        XCTAssertTrue(trip.destinations.isEmpty)
    }
    
    func testTripTotalDaysCalculation() throws {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 2, to: startDate)!
        
        let trip = Trip(title: "Test Trip", startDate: startDate, endDate: endDate)
        
        XCTAssertEqual(trip.totalDays, 3)
    }
    
    func testTripTotalDaysSameDate() throws {
        let sameDay = Date()
        let trip = Trip(title: "One Day Trip", startDate: sameDay, endDate: sameDay)
        
        XCTAssertEqual(trip.totalDays, 1)
    }
    
    func testTripDateRangeValidation() throws {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 5)
        
        let trip = Trip(title: "Five Day Trip", startDate: startDate, endDate: endDate)
        
        XCTAssertEqual(trip.totalDays, 6)
        XCTAssertTrue(trip.endDate > trip.startDate)
    }
    
    // MARK: - SwiftData Persistence Tests
    
    func testSaveAndFetchTrip() throws {
        let context = container.mainContext
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate)!
        let trip = Trip(title: "Surabaya Trip", startDate: startDate, endDate: endDate)
        
        context.insert(trip)
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrips = try context.fetch(descriptor)
        
        XCTAssertEqual(fetchedTrips.count, 1)
        XCTAssertEqual(fetchedTrips.first?.title, "Surabaya Trip")
    }
    
    func testUpdateTripProperties() throws {
        let context = container.mainContext
        
        let trip = Trip(title: "Original Title", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        trip.title = "Updated Title"
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrip = try context.fetch(descriptor).first
        
        XCTAssertEqual(fetchedTrip?.title, "Updated Title")
    }
    
    func testMultipleTrips() throws {
        let context = container.mainContext
        
        let trip1 = Trip(title: "Trip 1", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let trip2 = Trip(title: "Trip 2", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 2))
        let trip3 = Trip(title: "Trip 3", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 3))
        
        context.insert(trip1)
        context.insert(trip2)
        context.insert(trip3)
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(descriptor)
        
        XCTAssertEqual(trips.count, 3)
        
        let titles = trips.map { $0.title }.sorted()
        XCTAssertEqual(titles, ["Trip 1", "Trip 2", "Trip 3"])
    }
    
    func testDeleteTrip() throws {
        let context = container.mainContext
        
        let trip = Trip(title: "To Delete", startDate: Date(), endDate: Date().addingTimeInterval(86400))
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
        
        let tripC = Trip(title: "C Trip", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let tripA = Trip(title: "A Trip", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let tripB = Trip(title: "B Trip", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        context.insert(tripC)
        context.insert(tripA)
        context.insert(tripB)
        try context.save()
        
        var descriptor = FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.title)])
        let sortedTrips = try context.fetch(descriptor)
        
        XCTAssertEqual(sortedTrips.count, 3)
        XCTAssertEqual(sortedTrips[0].title, "A Trip")
        XCTAssertEqual(sortedTrips[1].title, "B Trip")
        XCTAssertEqual(sortedTrips[2].title, "C Trip")
    }
    
    func testTripEmptyDestinations() throws {
        let context = container.mainContext
        
        let trip = Trip(title: "Empty Trip", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        XCTAssertTrue(trip.destinations.isEmpty)
    }
    
    func testUpdateTripStartDate() throws {
        let context = container.mainContext
        
        let originalDate = Date()
        let trip = Trip(title: "Date Update Trip", startDate: originalDate, endDate: originalDate.addingTimeInterval(86400))
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
        
        let trip1 = Trip(title: "Bali Trip", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let trip2 = Trip(title: "Java Trip", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let trip3 = Trip(title: "Bali Holiday", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        context.insert(trip1)
        context.insert(trip2)
        context.insert(trip3)
        try context.save()
        
        let predicate = #Predicate<Trip> { $0.title.contains("Bali") }
        var descriptor = FetchDescriptor<Trip>(predicate: predicate)
        let results = try context.fetch(descriptor)
        
        XCTAssertEqual(results.count, 2)
    }
    
    func testTripTotalDaysTenDayTrip() throws {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 9, to: startDate)!
        let trip = Trip(title: "Ten Day Trip", startDate: startDate, endDate: endDate)
        
        XCTAssertEqual(trip.totalDays, 10)
    }
    
    func testMultipleSaveAndFetchCycle() throws {
        let context = container.mainContext
        
        // Cycle 1: Insert
        let trip1 = Trip(title: "First", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip1)
        try context.save()
        
        var descriptor = FetchDescriptor<Trip>()
        XCTAssertEqual(try context.fetch(descriptor).count, 1)
        
        // Cycle 2: Insert again
        let trip2 = Trip(title: "Second", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip2)
        try context.save()
        
        XCTAssertEqual(try context.fetch(descriptor).count, 2)
        
        // Cycle 3: Delete one
        context.delete(trip1)
        try context.save()
        
        XCTAssertEqual(try context.fetch(descriptor).count, 1)
        XCTAssertEqual(try context.fetch(descriptor).first?.title, "Second")
    }
}
