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
    
    @Relationship(deleteRule: .cascade) var destinations: [Destination] = []
    
    init(title: String, startDate: Date, endDate: Date) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // Menghitung durasi hari liburan otomatis
    var totalDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return max(1, (components.day ?? 0) + 1)
    }
}
