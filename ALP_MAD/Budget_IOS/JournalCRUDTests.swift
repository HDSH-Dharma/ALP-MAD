//
//  JournalCRUDTests.swift
//  ALP_MAD
//
//  Created by Dharma on 10/06/26.
//

import Testing
import Foundation
import SwiftData
@testable import ALP_MAD

@Suite("Journal Entry Validation")
@MainActor
struct JournalValidationTests {

    @Test("Non-empty title is valid")
    func validTitle() {
        let vm = TripJournalViewModel()
        vm.entryTitle = "Day 1"
        #expect(vm.isEntryValid == true)
    }

    @Test("Empty title is invalid")
    func emptyTitle() {
        let vm = TripJournalViewModel()
        vm.entryTitle = ""
        #expect(vm.isEntryValid == false)
    }

    @Test("Whitespace-only title is invalid")
    func whitespaceTitle() {
        let vm = TripJournalViewModel()
        vm.entryTitle = "   "
        #expect(vm.isEntryValid == false)
    }

    @Test("clearForm resets all fields")
    func clearForm() {
        let vm = TripJournalViewModel()
        vm.entryTitle     = "T"
        vm.entryNote      = "N"
        vm.entryPhotoData = Data([0x01])
        vm.showAddEntry   = true

        vm.clearForm()

        #expect(vm.entryTitle == "")
        #expect(vm.entryNote == "")
        #expect(vm.entryPhotoData == nil)
        #expect(vm.showAddEntry == false)
    }
}

@Suite("Journal Entry CRUD")
@MainActor
struct JournalCRUDTests {

    @Test("Add entry appends to trip")
    func addEntry() throws {
        let context = try makeContext()
        let trip = makeTrip()
        context.insert(trip)

        let vm = TripJournalViewModel()
        vm.entryTitle = "Sunset at Kuta"
        vm.entryNote  = "Beautiful evening"
        vm.addEntry(to: trip, context: context)

        #expect(trip.journalEntries.count == 1)
        #expect(trip.journalEntries.first?.title == "Sunset at Kuta")
        #expect(trip.journalEntries.first?.note == "Beautiful evening")
    }

    @Test("Add entry trims title and note")
    func addEntryTrims() throws {
        let context = try makeContext()
        let trip = makeTrip()
        context.insert(trip)

        let vm = TripJournalViewModel()
        vm.entryTitle = "  Hello  "
        vm.entryNote  = "  world  "
        vm.addEntry(to: trip, context: context)

        #expect(trip.journalEntries.first?.title == "Hello")
        #expect(trip.journalEntries.first?.note == "world")
    }

    @Test("Add entry keeps photo data")
    func addEntryPhoto() throws {
        let context = try makeContext()
        let trip = makeTrip()
        context.insert(trip)

        let vm = TripJournalViewModel()
        vm.entryTitle     = "With photo"
        vm.entryPhotoData = Data([0x10, 0x20, 0x30])
        vm.addEntry(to: trip, context: context)

        #expect(trip.journalEntries.first?.photoData == Data([0x10, 0x20, 0x30]))
    }

    @Test("Invalid (empty title) entry is not added")
    func invalidNotAdded() throws {
        let context = try makeContext()
        let trip = makeTrip()
        context.insert(trip)

        let vm = TripJournalViewModel()
        vm.entryTitle = "   "
        vm.entryNote  = "orphan note"
        vm.addEntry(to: trip, context: context)

        #expect(trip.journalEntries.isEmpty)
    }

    @Test("Add entry clears the form")
    func addClearsForm() throws {
        let context = try makeContext()
        let trip = makeTrip()
        context.insert(trip)

        let vm = TripJournalViewModel()
        vm.entryTitle   = "Entry"
        vm.showAddEntry = true
        vm.addEntry(to: trip, context: context)

        #expect(vm.entryTitle == "")
        #expect(vm.showAddEntry == false)
    }

    @Test("Delete entry removes it from trip")
    func deleteEntry() throws {
        let context = try makeContext()
        let trip = makeTrip()
        let entry = JournalEntry(title: "To delete")
        entry.trip = trip
        trip.journalEntries.append(entry)
        context.insert(trip)
        context.insert(entry)
        try context.save()

        let vm = TripJournalViewModel()
        vm.deleteEntry(entry, from: trip, context: context)

        #expect(trip.journalEntries.isEmpty)
    }

    @Test("Entries are returned newest first")
    func entriesSortedNewestFirst() throws {
        let context = try makeContext()
        let trip = makeTrip()
        let older = JournalEntry(title: "Older", date: date(2026, 6, 1))
        let newer = JournalEntry(title: "Newer", date: date(2026, 6, 3))
        older.trip = trip
        newer.trip = trip
        trip.journalEntries.append(contentsOf: [older, newer])
        context.insert(trip)
        try context.save()

        let vm = TripJournalViewModel()
        #expect(vm.entries(in: trip).map(\.title) == ["Newer", "Older"])
    }

    @Test("Entries empty for a new trip")
    func entriesEmpty() throws {
        let context = try makeContext()
        let trip = makeTrip()
        context.insert(trip)
        let vm = TripJournalViewModel()
        #expect(vm.entries(in: trip).isEmpty)
    }
}

@MainActor
private func makeContext() throws -> ModelContext {
    let schema = Schema([Trip.self, BudgetItem.self, Destination.self, JournalEntry.self])
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
    let start = date(2026, 6, 1)
    let end   = Calendar.current.date(byAdding: .day, value: days, to: start)!
    return Trip(name: name, destination: destination,
                startDate: start, endDate: end, currency: currency)
}
