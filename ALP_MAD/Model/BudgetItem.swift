//
//  BudgetItem.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftData
import Foundation

@Model
final class BudgetItem {
    var id: UUID
    var title: String
    var amount: Double
    var category: BudgetCategory
    var note: String
    var createdAt: Date
 
    // Relationship back to trip
    var trip: Trip?
 
    init(
        title: String,
        amount: Double,
        category: BudgetCategory,
        note: String = ""
    ) {
        self.id        = UUID()
        self.title     = title
        self.amount    = amount
        self.category  = category
        self.note      = note
        self.createdAt = Date()
    }
}
