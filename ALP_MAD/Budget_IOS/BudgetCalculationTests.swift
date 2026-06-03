//
//  BudgetCalculationTests.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//
import Testing
import Foundation
import SwiftData
@testable import ALP_MAD


@Suite("Budget Calculations")
    @MainActor
    struct BudgetCalculationTests {

        @Test("Total budget sums all items")
        func totalBudget() {
            let vm   = BudgetViewModel()
            let trip = makeTrip()
            trip.budgetItems = [
                BudgetItem(title: "A", amount: 300_000, category: .food),
                BudgetItem(title: "B", amount: 700_000, category: .transportation)
            ]
            #expect(vm.totalBudget(for: trip) == 1_000_000)
        }

        @Test("Total for category sums only that category")
        func totalForCategory() {
            let vm   = BudgetViewModel()
            let trip = makeTrip()
            trip.budgetItems = [
                BudgetItem(title: "A", amount: 300_000, category: .food),
                BudgetItem(title: "B", amount: 200_000, category: .food),
                BudgetItem(title: "C", amount: 700_000, category: .transportation)
            ]
            #expect(vm.total(for: .food, in: trip) == 500_000)
            #expect(vm.total(for: .transportation, in: trip) == 700_000)
        }

        @Test("Total for empty category returns 0")
        func totalEmptyCategory() {
            let vm   = BudgetViewModel()
            let trip = makeTrip()
            trip.budgetItems = [BudgetItem(title: "A", amount: 500_000, category: .food)]
            #expect(vm.total(for: .accommodation, in: trip) == 0)
        }

        @Test("Percentage sums to 1.0")
        func percentageSumsToOne() {
            let vm   = BudgetViewModel()
            let trip = makeTrip()
            trip.budgetItems = [
                BudgetItem(title: "A", amount: 250_000, category: .food),
                BudgetItem(title: "B", amount: 750_000, category: .transportation)
            ]
            let food      = vm.percentage(for: .food,           in: trip)
            let transport = vm.percentage(for: .transportation, in: trip)
            #expect(abs(food + transport - 1.0) < 0.001)
        }

        @Test("Percentage correct values")
        func percentageValues() {
            let vm   = BudgetViewModel()
            let trip = makeTrip()
            trip.budgetItems = [
                BudgetItem(title: "A", amount: 250_000, category: .food),
                BudgetItem(title: "B", amount: 750_000, category: .transportation)
            ]
            #expect(abs(vm.percentage(for: .transportation, in: trip) - 0.75) < 0.001)
            #expect(abs(vm.percentage(for: .food,           in: trip) - 0.25) < 0.001)
        }

        @Test("Percentage returns 0 when no items")
        func percentageEmptyTrip() {
            let vm   = BudgetViewModel()
            let trip = makeTrip()
            #expect(vm.percentage(for: .food, in: trip) == 0)
        }

        @Test("Category breakdown sorted by total descending")
        func breakdownSorted() {
            let vm   = BudgetViewModel()
            let trip = makeTrip()
            trip.budgetItems = [
                BudgetItem(title: "A", amount: 200_000,   category: .food),
                BudgetItem(title: "B", amount: 1_500_000, category: .accommodation),
                BudgetItem(title: "C", amount: 500_000,   category: .transportation)
            ]
            let bd = vm.categoryBreakdown(for: trip)
            #expect(bd.first?.category == .accommodation)
            #expect(bd.last?.category  == .food)
        }

        @Test("Category breakdown excludes zero categories")
        func breakdownExcludesZero() {
            let vm   = BudgetViewModel()
            let trip = makeTrip()
            trip.budgetItems = [BudgetItem(title: "A", amount: 500_000, category: .food)]
            let bd = vm.categoryBreakdown(for: trip)
            #expect(bd.count == 1)
            #expect(bd.first?.category == .food)
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

