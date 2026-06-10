//
//  WatchPayloadTests.swift
//  ALP_MAD
//
//  Created by Dharma on 10/06/26.
//

import Testing
import Foundation
@testable import ALP_MAD

@Suite("Watch Payload Mapping")
@MainActor
struct WatchPayloadMappingTests {

    @Test("Trip maps to payload with all fields")
    func tripMapsToPayload() {
        let trip = makeTrip()
        let item = BudgetItem(title: "Flight", amount: 800_000, category: .transportation, note: "SQ")
        trip.budgetItems = [item]

        let payloads = WatchConnectivityManager.payloads(from: [trip])

        #expect(payloads.count == 1)
        let p = payloads[0]
        #expect(p.id          == trip.id.uuidString)
        #expect(p.name        == "Test Trip")
        #expect(p.destination == "Bali")
        #expect(p.startDate   == trip.startDate)
        #expect(p.endDate     == trip.endDate)
        #expect(p.currency    == "IDR")
        #expect(p.items.count == 1)
        #expect(p.items.first?.title    == "Flight")
        #expect(p.items.first?.amount   == 800_000)
        #expect(p.items.first?.category == BudgetCategory.transportation.rawValue)
        #expect(p.items.first?.note     == "SQ")
    }

    @Test("Empty trip list maps to empty payload list")
    func emptyTrips() {
        #expect(WatchConnectivityManager.payloads(from: []).isEmpty)
    }

    @Test("Payloads survive encode/decode round-trip")
    func encodeDecodeRoundTrip() {
        let trip = makeTrip()
        trip.budgetItems = [BudgetItem(title: "Hotel", amount: 1_500_000, category: .accommodation)]
        let payloads = WatchConnectivityManager.payloads(from: [trip])

        let context = WatchConnectivityManager.encodeContext(payloads)
        #expect(context != nil)

        let decoded = WatchConnectivityManager.decodePayloads(from: context!)
        #expect(decoded?.count == 1)
        #expect(decoded?.first?.id == trip.id.uuidString)
        #expect(decoded?.first?.items.first?.amount == 1_500_000)
    }

    @Test("Decode fails gracefully when key is missing")
    func decodeMissingKey() {
        #expect(WatchConnectivityManager.decodePayloads(from: [:]) == nil)
    }

    @Test("Decode fails gracefully on corrupt data")
    func decodeCorruptData() {
        let garbage: [String: Any] = ["trips": Data([0x00, 0x01, 0x02])]
        #expect(WatchConnectivityManager.decodePayloads(from: garbage) == nil)
    }
}

@Suite("Watch Payload Calculations")
@MainActor
struct WatchPayloadCalculationTests {

    @Test("Total budget sums payload items")
    func totalBudget() {
        let vm = BudgetViewModel()
        let payload = makePayload(items: [
            makeItem(amount: 300_000, category: "Food & Drinks"),
            makeItem(amount: 700_000, category: "Transportation")
        ])
        #expect(vm.totalBudget(for: payload) == 1_000_000)
    }

    @Test("Total budget is 0 for empty payload")
    func totalBudgetEmpty() {
        let vm = BudgetViewModel()
        #expect(vm.totalBudget(for: makePayload(items: [])) == 0)
    }

    @Test("Breakdown groups by category and sorts descending")
    func breakdownGroupsAndSorts() {
        let vm = BudgetViewModel()
        let payload = makePayload(items: [
            makeItem(amount: 200_000, category: "Food & Drinks"),
            makeItem(amount: 300_000, category: "Food & Drinks"),
            makeItem(amount: 900_000, category: "Accommodation")
        ])
        let bd = vm.categoryBreakdown(for: payload)
        #expect(bd.count == 2)
        #expect(bd.first?.category == .accommodation)
        #expect(bd.first?.total == 900_000)
        #expect(bd.last?.category == .food)
        #expect(bd.last?.total == 500_000)
    }

    @Test("Breakdown percentages sum to 1.0")
    func breakdownPercentages() {
        let vm = BudgetViewModel()
        let payload = makePayload(items: [
            makeItem(amount: 250_000, category: "Food & Drinks"),
            makeItem(amount: 750_000, category: "Transportation")
        ])
        let sum = vm.categoryBreakdown(for: payload).reduce(0) { $0 + $1.percentage }
        #expect(abs(sum - 1.0) < 0.001)
    }

    @Test("Unknown category string falls back to Other")
    func unknownCategoryFallsBack() {
        let vm = BudgetViewModel()
        let payload = makePayload(items: [makeItem(amount: 100_000, category: "Nonexistent")])
        let bd = vm.categoryBreakdown(for: payload)
        #expect(bd.count == 1)
        #expect(bd.first?.category == .other)
    }

    @Test("Breakdown is empty for empty payload")
    func breakdownEmpty() {
        let vm = BudgetViewModel()
        #expect(vm.categoryBreakdown(for: makePayload(items: [])).isEmpty)
    }
}

// MARK: - Fixtures

private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
}

private func makeTrip(name: String = "Test Trip",
              destination: String = "Bali",
              days: Int = 5,
              currency: String = "IDR") -> Trip {
    let start = date(2026, 6, 1)
    let end   = Calendar.current.date(byAdding: .day, value: days, to: start)!
    return Trip(name: name, destination: destination,
                startDate: start, endDate: end, currency: currency)
}

private func makeItem(amount: Double, category: String) -> WatchItemPayload {
    WatchItemPayload(id: UUID().uuidString, title: "Item",
                     amount: amount, category: category, note: "")
}

private func makePayload(items: [WatchItemPayload]) -> WatchTripPayload {
    WatchTripPayload(id: UUID().uuidString, name: "Test Trip",
                     destination: "Bali",
                     startDate: date(2026, 6, 1), endDate: date(2026, 6, 6),
                     currency: "IDR", items: items)
}
