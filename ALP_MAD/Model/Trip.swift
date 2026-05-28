//
//  Trip.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//
//import Foundation
//import SwiftData
//
//@Model
//final class Trip {
//    var id: UUID
//    var name: String
//    var title: String
//    var destination: String
//    var startDate: Date
//    var endDate: Date
//    var currency: String
// 
//    @Relationship(deleteRule: .cascade) var destinations: [Destination] = []
//    @Relationship(deleteRule: .cascade, inverse: \BudgetItem.trip)
//    var budgetItems: [BudgetItem]
// 
//    init(
//        name: String,
//        title: String,
//        destination: String,
//        startDate: Date,
//        endDate: Date,
//        currency: String = "IDR"
//    ) {
//        self.id          = UUID()
//        self.name        = name
//        self.title       = title
//        self.destination = destination
//        self.startDate   = startDate
//        self.endDate     = endDate
//        self.currency    = currency
//        self.budgetItems = []
//    }
// 
//}

import Foundation
import SwiftData

@Model
final class Trip {
    var id: UUID = UUID()
    var title: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    // Relasi Cascade: Menghapus trip otomatis menghapus seluruh tujuannya
    @Relationship(deleteRule: .cascade) var destinations: [Destination] = []

    init(title: String, startDate: Date, endDate: Date) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
}
