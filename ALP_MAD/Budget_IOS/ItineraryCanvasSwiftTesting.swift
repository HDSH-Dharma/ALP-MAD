//
//  ItineraryCanvasSwiftTesting.swift
//  ALP_MADTests
//
//  Created by student on 03/06/26.
//

import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("Itinerary Canvas Swift Testing", .serialized)
struct ItineraryCanvasSwiftTesting {
    
    // MARK: - Trip Model Tests
    
    @Test("Trip initialization with basic properties")
    func testTripInitialization() throws {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate)!
        
        let trip = Trip(name: "Bali Trip", destination: "Bali", startDate: startDate, endDate: endDate)
        
        #expect(trip.name == "Bali Trip")
        #expect(trip.destination == "Bali")
        #expect(trip.startDate == startDate)
        #expect(trip.endDate == endDate)
        #expect(trip.destinations.isEmpty)
        #expect(trip.budgetItems.isEmpty) 
    }
    
    @Test("Trip totalDays calculation for multi-day trip")
    func testTripTotalDaysCalculation() throws {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 2, to: startDate)!
        
        let trip = Trip(name: "Test Trip", destination: "Test City", startDate: startDate, endDate: endDate)
        
        #expect(trip.totalDays == 3)
    }
    
    @Test("Trip totalDays is 1 when start and end date are same")
    func testTripTotalDaysSameDate() throws {
        let sameDay = Date()
        let trip = Trip(name: "One Day Trip", destination: "Test City", startDate: sameDay, endDate: sameDay)
        
        #expect(trip.totalDays == 1)
    }
    
    @Test("Trip date range validation")
    func testTripDateRangeValidation() throws {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 5)
        
        let trip = Trip(name: "Five Day Trip", destination: "Test City", startDate: startDate, endDate: endDate)
        
        #expect(trip.totalDays == 6)
        #expect(trip.endDate > trip.startDate)
    }
    
    // MARK: - SwiftData Persistence Tests - Trip Only
    
    @Test("Save and fetch single Trip")
    @MainActor
    func testSaveAndFetchTrip() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self, BudgetItem.self, // Added BudgetItem.self
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 2, to: startDate)!
        let trip = Trip(name: "Surabaya Trip", destination: "Surabaya", startDate: startDate, endDate: endDate)
        
        context.insert(trip)
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrips = try context.fetch(descriptor)
        
        #expect(fetchedTrips.count == 1)
        #expect(fetchedTrips.first?.name == "Surabaya Trip")
    }
    
    @Test("Update Trip properties")
    @MainActor
    func testUpdateTripProperties() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self, BudgetItem.self, // Added BudgetItem.self
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let trip = Trip(name: "Original Title", destination: "City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        trip.name = "Updated Title"
        try context.save()
        
        let descriptor = FetchDescriptor<Trip>()
        let fetchedTrip = try context.fetch(descriptor).first
        
        #expect(fetchedTrip?.name == "Updated Title")
    }
    
    @Test("Multiple Trips")
    @MainActor
    func testMultipleTrips() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self, BudgetItem.self, // Added BudgetItem.self
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
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
        
        #expect(trips.count == 3)
        
        let names = trips.map { $0.name }.sorted()
        #expect(names == ["Trip 1", "Trip 2", "Trip 3"])
    }
    
    @Test("Delete Trip")
    @MainActor
    func testDeleteTrip() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self, BudgetItem.self, // Added BudgetItem.self
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let trip = Trip(name: "To Delete", destination: "City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
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
            for: Trip.self, Destination.self, BudgetItem.self, // Added BudgetItem.self
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let tripC = Trip(name: "C Trip", destination: "City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let tripA = Trip(name: "A Trip", destination: "City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        let tripB = Trip(name: "B Trip", destination: "City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        
        context.insert(tripC)
        context.insert(tripA)
        context.insert(tripB)
        try context.save()
        
        var descriptor = FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.name)])
        let sortedTrips = try context.fetch(descriptor)
        
        #expect(sortedTrips.count == 3)
        #expect(sortedTrips[0].name == "A Trip")
        #expect(sortedTrips[1].name == "B Trip")
        #expect(sortedTrips[2].name == "C Trip")
    }
    
    @Test("Trip with empty destinations array")
    @MainActor
    func testTripEmptyDestinations() async throws {
        let container = try ModelContainer(
            for: Trip.self, Destination.self, BudgetItem.self, // Added BudgetItem.self
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        
        let trip = Trip(name: "Empty Trip", destination: "City", startDate: Date(), endDate: Date().addingTimeInterval(86400))
        context.insert(trip)
        try context.save()
        
        #expect(trip.destinations.isEmpty)
    }
}
