//
//  TripJournalVM.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData

@Observable
final class JournalViewModel {

    // MARK: - Form state
    var showAddEntry   = false
    var entryTitle     = ""
    var entryNote      = ""
    var entryPhotoData: Data? = nil

    // MARK: - Validation
    var isEntryValid: Bool {
        !entryTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Read
    /// Journal entries of a trip, newest first.
    func entries(in trip: Trip) -> [JournalEntry] {
        trip.journalEntries.sorted { $0.date > $1.date }
    }

    // MARK: - CRUD
    func addEntry(to trip: Trip, context: ModelContext) {
        guard isEntryValid else { return }
        let entry = JournalEntry(
            title:     entryTitle.trimmingCharacters(in: .whitespaces),
            note:      entryNote.trimmingCharacters(in: .whitespaces),
            photoData: entryPhotoData
        )
        entry.trip = trip
        trip.journalEntries.append(entry)
        context.insert(entry)
        try? context.save()
        clearForm()
    }

    func deleteEntry(_ entry: JournalEntry, from trip: Trip, context: ModelContext) {
        trip.journalEntries.removeAll { $0.id == entry.id }
        context.delete(entry)
        try? context.save()
    }

    // MARK: - Form helpers
    func clearForm() {
        entryTitle     = ""
        entryNote      = ""
        entryPhotoData = nil
        showAddEntry   = false
    }

    // MARK: - Formatting
    func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
