//
//  Trip.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

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
