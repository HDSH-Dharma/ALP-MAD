//
//  ItemFormValidationTests.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("Item Form Validation")
@MainActor
struct ItemFormValidationTests {

    @Test("Valid form passes")
    func validFormPasses() {
        let vm = BudgetViewModel()
        vm.itemTitle  = "Flight"
        vm.itemAmount = "500000"
        #expect(vm.isItemFormValid == true)
    }

    @Test("Empty title fails")
    func emptyTitleFails() {
        let vm = BudgetViewModel()
        vm.itemTitle  = ""
        vm.itemAmount = "500000"
        #expect(vm.isItemFormValid == false)
    }

    @Test("Whitespace-only title fails")
    func whitespaceTitleFails() {
        let vm = BudgetViewModel()
        vm.itemTitle  = "   "
        vm.itemAmount = "500000"
        #expect(vm.isItemFormValid == false)
    }

    @Test("Empty amount fails")
    func emptyAmountFails() {
        let vm = BudgetViewModel()
        vm.itemTitle  = "Flight"
        vm.itemAmount = ""
        #expect(vm.isItemFormValid == false)
    }

    @Test("Non-numeric amount fails")
    func nonNumericAmountFails() {
        let vm = BudgetViewModel()
        vm.itemTitle  = "Flight"
        vm.itemAmount = "abc"
        #expect(vm.isItemFormValid == false)
    }

    @Test("Zero amount fails")
    func zeroAmountFails() {
        let vm = BudgetViewModel()
        vm.itemTitle  = "Flight"
        vm.itemAmount = "0"
        #expect(vm.isItemFormValid == false)
    }

    @Test("Negative amount fails")
    func negativeAmountFails() {
        let vm = BudgetViewModel()
        vm.itemTitle  = "Flight"
        vm.itemAmount = "-500"
        #expect(vm.isItemFormValid == false)
    }

    @Test("Comma-grouped amount passes")
    func commaAmountPasses() {
        let vm = BudgetViewModel()
        vm.itemTitle  = "Hotel"
        vm.itemAmount = "1,500,000"
        #expect(vm.isItemFormValid == true)
    }

    @Test("Dot-grouped amount passes")
    func dotAmountPasses() {
        let vm = BudgetViewModel()
        vm.itemTitle  = "Hotel"
        vm.itemAmount = "1.500.000"
        #expect(vm.isItemFormValid == true)
    }
}

@Suite("Trip Form Validation")
@MainActor
struct TripFormValidationTests {

    @Test("Valid form passes")
    func validFormPasses() {
        let vm = BudgetViewModel()
        vm.tripName        = "Bali Summer"
        vm.tripDestination = "Bali"
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)
        #expect(vm.isTripFormValid == true)
    }

    @Test("Empty name fails")
    func emptyNameFails() {
        let vm = BudgetViewModel()
        vm.tripName        = ""
        vm.tripDestination = "Bali"
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)
        #expect(vm.isTripFormValid == false)
    }

    @Test("Whitespace-only name fails")
    func whitespaceNameFails() {
        let vm = BudgetViewModel()
        vm.tripName        = "   "
        vm.tripDestination = "Bali"
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)
        #expect(vm.isTripFormValid == false)
    }

    @Test("Empty destination fails")
    func emptyDestinationFails() {
        let vm = BudgetViewModel()
        vm.tripName        = "Trip"
        vm.tripDestination = ""
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)
        #expect(vm.isTripFormValid == false)
    }

    @Test("Whitespace-only destination fails")
    func whitespaceDestinationFails() {
        let vm = BudgetViewModel()
        vm.tripName        = "Trip"
        vm.tripDestination = "   "
        vm.tripStartDate   = date(2026, 6, 1)
        vm.tripEndDate     = date(2026, 6, 6)
        #expect(vm.isTripFormValid == false)
    }

    @Test("End date before start fails")
    func endBeforeStartFails() {
        let vm = BudgetViewModel()
        vm.tripName        = "Trip"
        vm.tripDestination = "Dest"
        vm.tripStartDate   = date(2026, 6, 5)
        vm.tripEndDate     = date(2026, 6, 4)
        #expect(vm.isTripFormValid == false)
    }

    @Test("End date equal to start fails")
    func endEqualStartFails() {
        let vm  = BudgetViewModel()
        let day = date(2026, 6, 5)
        vm.tripName        = "Trip"
        vm.tripDestination = "Dest"
        vm.tripStartDate   = day
        vm.tripEndDate     = day
        #expect(vm.isTripFormValid == false)
    }
}

private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
}
