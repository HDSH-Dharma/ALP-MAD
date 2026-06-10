//
//  ItemCRUDTests.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//


import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("BudgetItem CRUD")
    @MainActor
    struct ItemCRUDTests {

        @Test("Add item appends to trip")
        func addItem() throws {
            let context = try makeContext()
            let trip = makeTrip()
            context.insert(trip)

            let vm = BudgetViewModel()
            vm.itemTitle    = "Flight"
            vm.itemAmount   = "500000"
            vm.itemCategory = .transportation

            vm.addItem(to: trip, context: context)

            #expect(trip.budgetItems.count == 1)
            #expect(trip.budgetItems.first?.title == "Flight")
            #expect(trip.budgetItems.first?.amount == 500_000)
            #expect(trip.budgetItems.first?.category == .transportation)
        }

        @Test("Add item with comma-formatted amount")
        func addItemCommaAmount() throws {
            let context = try makeContext()
            let trip = makeTrip()
            context.insert(trip)

            let vm = BudgetViewModel()
            vm.itemTitle    = "Hotel"
            vm.itemAmount   = "1,500,000"
            vm.itemCategory = .accommodation

            vm.addItem(to: trip, context: context)
            #expect(trip.budgetItems.first?.amount == 1_500_000)
        }

        @Test("Add item with dot-formatted amount (Indonesian style)")
        func addItemDotAmount() throws {
            let context = try makeContext()
            let trip = makeTrip()
            context.insert(trip)

            let vm = BudgetViewModel()
            vm.itemTitle    = "Hotel"
            vm.itemAmount   = "1.500.000"
            vm.itemCategory = .accommodation

            vm.addItem(to: trip, context: context)
            #expect(trip.budgetItems.first?.amount == 1_500_000)
        }

        @Test("Add item trims title and note")
        func addItemTrims() throws {
            let context = try makeContext()
            let trip = makeTrip()
            context.insert(trip)

            let vm = BudgetViewModel()
            vm.itemTitle  = "  Flight  "
            vm.itemAmount = "500000"
            vm.itemNote   = "  window seat  "

            vm.addItem(to: trip, context: context)
            #expect(trip.budgetItems.first?.title == "Flight")
            #expect(trip.budgetItems.first?.note  == "window seat")
        }

        @Test("Invalid form does not add item")
        func invalidFormDoesNotAdd() throws {
            let context = try makeContext()
            let trip = makeTrip()
            context.insert(trip)

            let vm = BudgetViewModel()
            vm.itemTitle  = ""
            vm.itemAmount = "500000"
            vm.addItem(to: trip, context: context)

            vm.itemTitle  = "Flight"
            vm.itemAmount = "0"
            vm.addItem(to: trip, context: context)

            vm.itemAmount = "abc"
            vm.addItem(to: trip, context: context)

            #expect(trip.budgetItems.isEmpty)
        }

        @Test("Update item mutates fields")
        func updateItem() throws {
            let context = try makeContext()
            let trip = makeTrip()
            let item = BudgetItem(title: "Old", amount: 100_000, category: .food)
            item.trip = trip
            trip.budgetItems.append(item)
            context.insert(trip)
            context.insert(item)
            try context.save()

            let vm = BudgetViewModel()
            vm.itemTitle    = "New Title"
            vm.itemAmount   = "250000"
            vm.itemCategory = .accommodation
            vm.updateItem(item, context: context)

            #expect(item.title    == "New Title")
            #expect(item.amount   == 250_000)
            #expect(item.category == .accommodation)
        }

        @Test("Update with invalid form leaves item unchanged")
        func updateInvalidFormNoOp() throws {
            let context = try makeContext()
            let trip = makeTrip()
            let item = BudgetItem(title: "Old", amount: 100_000, category: .food)
            item.trip = trip
            trip.budgetItems.append(item)
            context.insert(trip)
            context.insert(item)
            try context.save()

            let vm = BudgetViewModel()
            vm.itemTitle  = ""
            vm.itemAmount = "250000"
            vm.updateItem(item, context: context)

            #expect(item.title  == "Old")
            #expect(item.amount == 100_000)
        }

        @Test("Delete item removes from trip")
        func deleteItem() throws {
            let context = try makeContext()
            let trip = makeTrip()
            let item = BudgetItem(title: "Hotel", amount: 1_000_000, category: .accommodation)
            item.trip = trip
            trip.budgetItems.append(item)
            context.insert(trip)
            context.insert(item)
            try context.save()

            let vm = BudgetViewModel()
            vm.deleteItem(item, from: trip, context: context)

            #expect(trip.budgetItems.isEmpty)
        }

        @Test("Add multiple items to one trip")
        func addMultipleItems() throws {
            let context = try makeContext()
            let trip = makeTrip()
            context.insert(trip)
            let vm = BudgetViewModel()

            for (title, amount) in [("Flight", "300000"), ("Hotel", "700000"), ("Food", "200000")] {
                vm.itemTitle  = title
                vm.itemAmount = amount
                vm.addItem(to: trip, context: context)
            }

            #expect(trip.budgetItems.count == 3)
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
    let start = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
    let end   = Calendar.current.date(byAdding: .day, value: days, to: start)!
    return Trip(name: name, destination: destination,
                startDate: start, endDate: end, currency: currency)
}
