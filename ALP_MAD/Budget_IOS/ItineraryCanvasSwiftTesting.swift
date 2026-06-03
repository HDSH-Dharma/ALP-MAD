//
//  ItineraryCanvasSwiftTesting.swift
//  ALP_MADTests
//
//  Created by student on 03/06/26.
//

import SwiftUI
import Testing
import SwiftData
@testable import ALP_MAD

@Suite("Itinerary Canvas Swift Testing", .serialized)
struct ItineraryCanvasSwiftTesting {
    
    // MARK: - Trip Model Tests
    
    @Test("Trip initialization with basic properties")
    func testTripInitialization() throws {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
        let trip = Trip(title: "Bali Trip", startDate: startDate, endDate: endDate)
        
        #expect(trip.title == "Bali Trip")
        #expect(trip.startDate == startDate)
        #expect(trip.endDate == endDate)
        #expect(trip.destinations.isEmpty)
    }
    
    @Test("Trip totalDays calculation for multi-day trip")
    func testTripTotalDaysCalculation() throws {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 2, to: startDate)!
        
        let trip = Trip(title: "Test Trip", startDate: startDate, endDate: endDate)
        
        #expect(trip.totalDays == 3)
    }
    
    @Test("Trip totalDays is 1 when start and end date are same")
    func testTripTotalDaysSameDate() throws {
        let sameDay = Date()
        let trip = Trip(title: "One Day Trip", startDate: sameDay, endDate: sameDay)
        
        #expect(trip.totalDays == 1)
    }
    
    @Test("Trip date range validation")
    func testTripDateRangeValidation() throws {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 5)
        
        let trip = Trip(title: "Five Day Trip", startDate: startDate, endDate: endDate)
        
        #expect(trip.totalDays == 6)
        #expect(trip.endDate > trip.startDate)
    }
    
    // MARK: - SwiftData Persistence Tests - Trip Only
    
    @Test("Save and fetch single Trip")
    @MainActor
    func testSaveAndFetchTrip() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate)!
        let trip = Trip(title: "Surabaya Trip", startDate: startDate, endDate: endDate)
        
        context.insert(trip)
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrips = try context.fetch(descriptor)
        
        #expect(fetchedTrips.count == 1)
        #expect(fetchedTrips.first?.title == "Surabaya Trip")
    }
    
    @Test("Update Trip properties")
    @MainActor
    func testUpdateTripProperties() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let trip = Trip(title: "Original Title", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        trip.title = "Updated Title"
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrip = try context.fetch(descriptor).first
        
        #expect(fetchedTrip?.title == "Updated Title")
    }
    
    @Test("Multiple Trips")
    @MainActor
    func testMultipleTrips() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
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
        
        #expect(trips.count == 3)
        
        let titles = trips.map { $0.title }.sorted()
        #expect(titles == ["Trip 1", "Trip 2", "Trip 3"])
    }
    
    @Test("Delete Trip")
    @MainActor
    func testDeleteTrip() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let trip = Trip(title: "To Delete", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        context.delete(trip)
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(descriptor)
        
        #expect(trips.isEmpty)
    }
    
    @Test("Fetch Trip with sort descriptor")
    @MainActor
    func testFetchTripWithSort() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
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
        
        #expect(sortedTrips.count == 3)
        #expect(sortedTrips[0].title == "A Trip")
        #expect(sortedTrips[1].title == "B Trip")
        #expect(sortedTrips[2].title == "C Trip")
    }
    
    @Test("Trip with empty destinations array")
    @MainActor
    func testTripEmptyDestinations() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let trip = Trip(title: "Empty Trip", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        #expect(trip.destinations.isEmpty)
    }
}
