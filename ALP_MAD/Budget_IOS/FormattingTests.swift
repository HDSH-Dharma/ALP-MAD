//
//  FormattingTests.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import Testing
import Foundation
import SwiftData
@testable import ALP_MAD


@Suite("Formatting")
    @MainActor
    struct FormattingTests {

        @Test("IDR formatted without decimals")
        func idrNoDecimals() {
            let vm     = BudgetViewModel()
            let result = vm.formatCurrency(1_500_000, currency: "IDR")
            #expect(result.contains("1.500.000") || result.contains("1,500,000"))
            #expect(!result.contains(".00"))
        }

        @Test("USD formatted with decimals")
        func usdWithDecimals() {
            let vm     = BudgetViewModel()
            let result = vm.formatCurrency(99.99, currency: "USD")
            #expect(result.contains("99.99") || result.contains("99,99"))
        }

        @Test("Duration singular day")
        func durationSingular() {
            let vm    = BudgetViewModel()
            let trip  = makeTrip(days: 1)
            #expect(vm.durationText(trip: trip) == "1 day")
        }

        @Test("Duration plural days")
        func durationPlural() {
            let vm   = BudgetViewModel()
            let trip = makeTrip(days: 7)
            #expect(vm.durationText(trip: trip) == "7 days")
        }

        @Test("Duration specific dates")
        func durationSpecificDates() {
            let vm    = BudgetViewModel()
            let start = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
            let end   = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 8))!
            let trip  = Trip(name: "T", destination: "D", startDate: start, endDate: end)
            #expect(vm.durationText(trip: trip) == "7 days")
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

