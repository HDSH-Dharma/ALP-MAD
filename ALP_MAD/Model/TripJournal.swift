//
//  TripJournal.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation

struct TripJournal: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let entry: String
    let image: String
    let date: Date

    init(title: String, entry: String, image: String, date: Date = Date()) {
        self.title = title
        self.entry = entry
        self.image = image
        self.date = date
    }
}
