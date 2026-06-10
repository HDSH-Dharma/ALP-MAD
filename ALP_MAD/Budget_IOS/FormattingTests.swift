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
            #expect(!result.hasSuffix(".00"))
            #expect(!result.hasSuffix(",00"))
        }

        @Test("USD formatted with decimals")
        func usdWithDecimals() {
            let vm     = BudgetViewModel()
            let result = vm.formatCurrency(99.99, currency: "USD")
            #expect(result.contains("99.99") || result.contains("99,99"))
        }

        @Test("Zero amount formats without crashing")
        func zeroAmount() {
            let vm     = BudgetViewModel()
            let result = vm.formatCurrency(0, currency: "IDR")
            #expect(result.contains("0"))
        }

        @Test("formatRaw whole amount has no grouping separator")
        func formatRawWhole() {
            let vm = BudgetViewModel()
            #expect(vm.formatRaw(1_500_000) == "1500000")
        }

        @Test("formatRaw keeps up to two decimals")
        func formatRawDecimals() {
            let vm = BudgetViewModel()
            #expect(vm.formatRaw(99.99) == "99.99")
        }

        @Test("formatRaw round-trips through parseAmount")
        func formatRawRoundTrip() {
            let vm = BudgetViewModel()
            for amount in [0.5, 99.99, 1_500.0, 1_500_000.0] {
                let parsed = BudgetViewModel.parseAmount(vm.formatRaw(amount))
                #expect(parsed == amount)
            }
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
            let trip  = Trip(name: "T", destination: "D",
                             startDate: date(2026, 6, 1), endDate: date(2026, 6, 8))
            #expect(vm.durationText(trip: trip) == "7 days")
        }

        @Test("Duration ignores time of day")
        func durationIgnoresTimeOfDay() {
            let vm    = BudgetViewModel()
            let start = date(2026, 6, 1, hour: 23)
            let end   = date(2026, 6, 3, hour: 1)
            #expect(vm.durationDays(from: start, to: end) == 2)
        }
    }

@Suite("Amount Parsing")
struct AmountParsingTests {

    @Test("Plain digits parse")
    func plainDigits() {
        #expect(BudgetViewModel.parseAmount("500000") == 500_000)
    }

    @Test("Comma thousands separators parse")
    func commaGrouping() {
        #expect(BudgetViewModel.parseAmount("1,500,000") == 1_500_000)
        #expect(BudgetViewModel.parseAmount("1,500") == 1_500)
    }

    @Test("Dot thousands separators parse (Indonesian style)")
    func dotGrouping() {
        #expect(BudgetViewModel.parseAmount("1.500.000") == 1_500_000)
        #expect(BudgetViewModel.parseAmount("1.500") == 1_500)
    }

    @Test("Dot decimal separator parses")
    func dotDecimal() {
        #expect(BudgetViewModel.parseAmount("99.99") == 99.99)
        #expect(BudgetViewModel.parseAmount("0.5") == 0.5)
    }

    @Test("Comma decimal separator parses")
    func commaDecimal() {
        #expect(BudgetViewModel.parseAmount("99,99") == 99.99)
        #expect(BudgetViewModel.parseAmount("0,5") == 0.5)
    }

    @Test("Mixed separators use rightmost as decimal")
    func mixedSeparators() {
        #expect(BudgetViewModel.parseAmount("1,500.50") == 1_500.5)
        #expect(BudgetViewModel.parseAmount("1.500,50") == 1_500.5)
    }

    @Test("Surrounding whitespace is ignored")
    func whitespace() {
        #expect(BudgetViewModel.parseAmount("  500000  ") == 500_000)
    }

    @Test("Empty string fails")
    func emptyFails() {
        #expect(BudgetViewModel.parseAmount("") == nil)
        #expect(BudgetViewModel.parseAmount("   ") == nil)
    }

    @Test("Non-numeric input fails")
    func nonNumericFails() {
        #expect(BudgetViewModel.parseAmount("abc") == nil)
        #expect(BudgetViewModel.parseAmount("12a") == nil)
    }
}

private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
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
