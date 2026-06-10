//
//  TripCRUDTests.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("Trip CRUD")
@MainActor
struct TripCRUDTests {

    @Test("Create trip saves to context")
    func createTrip() throws {
        let context = try makeContext()
        let vm = BudgetViewModel()
        vm.tripName        = "Bali Summer"
        vm.tripDestination = "Bali"
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)
        vm.tripCurrency    = "IDR"

        vm.addTrip(context: context)

        let trips = try context.fetch(FetchDescriptor<Trip>())
        #expect(trips.count == 1)
        #expect(trips.first?.name == "Bali Summer")
        #expect(trips.first?.destination == "Bali")
        #expect(trips.first?.currency == "IDR")
    }

    @Test("Create trip sets selectedTrip")
    func createTripSetsSelection() throws {
        let context = try makeContext()
        let vm = BudgetViewModel()
        vm.tripName        = "Bali Summer"
        vm.tripDestination = "Bali"
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)

        vm.addTrip(context: context)
        #expect(vm.selectedTrip != nil)
        #expect(vm.selectedTrip?.name == "Bali Summer")
    }

    @Test("Create trip clears form")
    func createTripClearsForm() throws {
        let context = try makeContext()
        let vm = BudgetViewModel()
        vm.tripName        = "Bali Summer"
        vm.tripDestination = "Bali"
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)

        vm.addTrip(context: context)
        #expect(vm.tripName        == "")
        #expect(vm.tripDestination == "")
        #expect(vm.showAddTrip     == false)
    }

    @Test("Create trip trims name and destination")
    func createTripTrims() throws {
        let context = try makeContext()
        let vm = BudgetViewModel()
        vm.tripName        = "  Bali Summer  "
        vm.tripDestination = "  Bali  "
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)

        vm.addTrip(context: context)

        let trips = try context.fetch(FetchDescriptor<Trip>())
        #expect(trips.first?.name == "Bali Summer")
        #expect(trips.first?.destination == "Bali")
    }

    @Test("Invalid form does not save trip")
    func invalidFormDoesNotSave() throws {
        let context = try makeContext()
        let vm = BudgetViewModel()
        vm.tripName        = ""
        vm.tripDestination = "Bali"

        vm.addTrip(context: context)

        let trips = try context.fetch(FetchDescriptor<Trip>())
        #expect(trips.isEmpty)
    }

    @Test("Delete trip removes from context")
    func deleteTrip() throws {
        let context = try makeContext()
        let trip = makeTrip()
        context.insert(trip)
        try context.save()

        let vm = BudgetViewModel()
        vm.deleteTrip(trip, context: context)

        let trips = try context.fetch(FetchDescriptor<Trip>())
        #expect(trips.isEmpty)
    }

    @Test("Delete trip clears selectedTrip")
    func deleteTripClearsSelection() throws {
        let context = try makeContext()
        let trip = makeTrip()
        context.insert(trip)
        try context.save()

        let vm = BudgetViewModel()
        vm.selectedTrip = trip
        vm.deleteTrip(trip, context: context)

        #expect(vm.selectedTrip == nil)
    }

    @Test("Delete non-selected trip keeps selectedTrip")
    func deleteNonSelectedTripKeepsSelection() throws {
        let context = try makeContext()
        let trip1 = makeTrip(name: "Trip 1")
        let trip2 = makeTrip(name: "Trip 2")
        context.insert(trip1)
        context.insert(trip2)
        try context.save()

        let vm = BudgetViewModel()
        vm.selectedTrip = trip1
        vm.deleteTrip(trip2, context: context)

        #expect(vm.selectedTrip?.name == "Trip 1")
    }
}

@MainActor
private func makeContext() throws -> ModelContext {
    let schema = Schema([Trip.self, BudgetItem.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [config])
    return ModelContext(container)
}

private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
}

private func makeTrip(name: String = "Test Trip",
              destination: String = "Bali",
              days: Int = 5,
              currency: String = "IDR") -> Trip {
    let start = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
    let end   = Calendar.current.date(byAdding: .day, value: days, to: start)!
    return Trip(name: name, destination: destination,
                startDate: start, endDate: end, currency: currency)
}
