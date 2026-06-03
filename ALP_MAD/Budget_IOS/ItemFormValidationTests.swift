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

@Suite("Trip Form Validation")
@MainActor
struct TripFormValidationTests {
    
    @Test("Valid form passes")
    func validFormPasses() {
        let vm = BudgetViewModel()
        vm.tripName        = "Bali Summer"
        vm.tripDestination = "Bali"
        vm.tripStartDate   = Date()
        vm.tripEndDate     = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        #expect(vm.isTripFormValid == true)
    }
    
    @Test("Empty name fails")
    func emptyNameFails() {
        let vm = BudgetViewModel()
        vm.tripName        = ""
        vm.tripDestination = "Bali"
        vm.tripEndDate     = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        #expect(vm.isTripFormValid == false)
    }
    
    @Test("Whitespace-only name fails")
    func whitespaceNameFails() {
        let vm = BudgetViewModel()
        vm.tripName        = "   "
        vm.tripDestination = "Bali"
        vm.tripEndDate     = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        #expect(vm.isTripFormValid == false)
    }
    
    @Test("Empty destination fails")
    func emptyDestinationFails() {
        let vm = BudgetViewModel()
        vm.tripName        = "Trip"
        vm.tripDestination = ""
        vm.tripEndDate     = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        #expect(vm.isTripFormValid == false)
    }
    
    @Test("Whitespace-only destination fails")
    func whitespaceDestinationFails() {
        let vm = BudgetViewModel()
        vm.tripName        = "Trip"
        vm.tripDestination = "   "
        vm.tripEndDate     = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        #expect(vm.isTripFormValid == false)
    }
    
    @Test("End date before start fails")
    func endBeforeStartFails() {
        let vm = BudgetViewModel()
        vm.tripName        = "Trip"
        vm.tripDestination = "Dest"
        vm.tripStartDate   = Date()
        vm.tripEndDate     = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        #expect(vm.isTripFormValid == false)
    }
    
    @Test("End date equal to start fails")
    func endEqualStartFails() {
        let vm  = BudgetViewModel()
        let now = Date()
        vm.tripName        = "Trip"
        vm.tripDestination = "Dest"
        vm.tripStartDate   = now
        vm.tripEndDate     = now
        #expect(vm.isTripFormValid == false)
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


