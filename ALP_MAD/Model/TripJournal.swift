//
//  TripJournal.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData

/// A single trip journal entry: a dated note with an optional photo,
/// belonging to one Trip. Persisted with SwiftData.
@Model
final class JournalEntry {
    var id: UUID
    var title: String
    var note: String
    var date: Date

    // Photo picked from the gallery, stored as JPEG/PNG data.
    @Attribute(.externalStorage) var photoData: Data?

    var trip: Trip?

    init(
        title: String,
        note: String = "",
        date: Date = Date(),
        photoData: Data? = nil
    ) {
        self.id        = UUID()
        self.title     = title
        self.note      = note
        self.date      = date
        self.photoData = photoData
    }
}
