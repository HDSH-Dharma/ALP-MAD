//
//  BudgetWatch_Watch_AppTests.swift
//  BudgetWatch Watch AppTests
//
//  Created by Dharma on 03/06/26.
//

import Testing
import Foundation
@testable import BudgetWatch_Watch_App

struct BudgetWatch_Watch_AppTests {

    @Test("Total budget sums payload items")
    @MainActor
    func totalBudget() {
        let vm = BudgetViewModel()
        let payload = makePayload(items: [
            makeItem(amount: 300_000, category: "Food & Drinks"),
            makeItem(amount: 700_000, category: "Transportation")
        ])
        #expect(vm.totalBudget(for: payload) == 1_000_000)
    }

    @Test("Breakdown groups categories and sorts descending")
    @MainActor
    func breakdownGroupsAndSorts() {
        let vm = BudgetViewModel()
        let payload = makePayload(items: [
            makeItem(amount: 200_000, category: "Food & Drinks"),
            makeItem(amount: 900_000, category: "Accommodation")
        ])
        let bd = vm.categoryBreakdown(for: payload)
        #expect(bd.first?.category == .accommodation)
        #expect(bd.last?.category  == .food)
    }

    @Test("Unknown category falls back to Other")
    @MainActor
    func unknownCategoryFallsBack() {
        let vm = BudgetViewModel()
        let payload = makePayload(items: [makeItem(amount: 100_000, category: "???")])
        #expect(vm.categoryBreakdown(for: payload).first?.category == .other)
    }

    @Test("Duration ignores time of day")
    @MainActor
    func durationIgnoresTimeOfDay() {
        let vm    = BudgetViewModel()
        let start = date(2026, 6, 1, hour: 23)
        let end   = date(2026, 6, 3, hour: 1)
        #expect(vm.durationDays(from: start, to: end) == 2)
    }
}

private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
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
