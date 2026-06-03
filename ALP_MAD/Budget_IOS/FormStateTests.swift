//
//  FormStateTests.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//


import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("Form State")
    @MainActor
    struct FormStateTests {

        @Test("clearItemForm resets all fields")
        func clearItemForm() {
            let vm = BudgetViewModel()
            vm.itemTitle    = "Hotel"
            vm.itemAmount   = "500000"
            vm.itemCategory = .accommodation
            vm.itemNote     = "Nice place"
            vm.showAddItem  = true

            vm.clearItemForm()

            #expect(vm.itemTitle    == "")
            #expect(vm.itemAmount   == "")
            #expect(vm.itemCategory == .transportation)
            #expect(vm.itemNote     == "")
            #expect(vm.showAddItem  == false)
            #expect(vm.editingItem  == nil)
        }

        @Test("populateItemForm fills fields from item")
        func populateItemForm() {
            let vm   = BudgetViewModel()
            let item = BudgetItem(title: "Flight", amount: 800_000, category: .transportation, note: "SQ")
            vm.populateItemForm(from: item)

            #expect(vm.itemTitle    == "Flight")
            #expect(vm.itemCategory == .transportation)
            #expect(vm.itemNote     == "SQ")
        }

        @Test("clearTripForm resets all fields")
        func clearTripForm() {
            let vm = BudgetViewModel()
            vm.tripName        = "Trip"
            vm.tripDestination = "Dest"
            vm.showAddTrip     = true

            vm.clearTripForm()

            #expect(vm.tripName        == "")
            #expect(vm.tripDestination == "")
            #expect(vm.showAddTrip     == false)
        }
    }

@MainActor
private func makeContext() throws -> ModelContext {
    let schema = Schema([Trip.self, BudgetItem.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [config])
    return ModelContext(container)
}

private func makeTrip(name: String = "Test Trip",
              destination: String = "Bali",
              days: Int = 5,
              currency: String = "IDR") -> Trip {
    let start = Date()
    let end   = Calendar.current.date(byAdding: .day, value: days, to: start)!
    return Trip(name: name, destination: destination,
                startDate: start, endDate: end, currency: currency)
}

