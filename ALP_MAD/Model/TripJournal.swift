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
    let day: Int
    let entries: [String]
    let date: Date
}
