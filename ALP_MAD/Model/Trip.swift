//
//  Trip.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//
import Foundation
import SwiftData

@Model
final class Trip: Hashable {
    var id: UUID
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var currency: String
 
    @Relationship(deleteRule: .cascade, inverse: \BudgetItem.trip)
    var budgetItems: [BudgetItem]
 
    @Relationship(deleteRule: .cascade)
    var destinations: [Destination]
    
    init(
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        currency: String = "IDR"
    ) {
        self.id           = UUID()
        self.name         = name
        self.destination  = destination
        self.startDate    = startDate
        self.endDate      = endDate
        self.currency     = currency
        self.budgetItems  = []
        self.destinations = []
    }

    /// Convenience init for the itinerary flow, which only supplies a title.
    /// Bridges to the unified name-based model; destination/currency take
    /// defaults and can be filled in later from the budget side.
    convenience init(title: String, startDate: Date, endDate: Date) {
        self.init(name: title, destination: "", startDate: startDate, endDate: endDate)
    }

    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.persistentModelID == rhs.persistentModelID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }

}
extension Trip {
    /// The itinerary feature refers to the trip headline as `title`, while the
    /// budget feature uses `name`. They are the same underlying value — this
    /// bridges both vocabularies onto the single stored `name` property so
    /// neither feature's code needs to change.
    var title: String {
        get { name }
        set { name = newValue }
    }

    var totalDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(1, (components.day ?? 0) + 1)
    }
}

