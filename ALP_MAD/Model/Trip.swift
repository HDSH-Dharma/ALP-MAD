//
//  Trip.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//
import Foundation
import SwiftData

@Model
final class Trip {
    var id: UUID
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var currency: String
 
    @Relationship(deleteRule: .cascade, inverse: \BudgetItem.trip)
    var budgetItems: [BudgetItem]
 
    init(
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        currency: String = "IDR"
    ) {
        self.id          = UUID()
        self.name        = name
        self.destination = destination
        self.startDate   = startDate
        self.endDate     = endDate
        self.currency    = currency
        self.budgetItems = []
    }
 
}
