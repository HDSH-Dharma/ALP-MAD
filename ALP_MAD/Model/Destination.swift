//
//  Destination.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData

@Model
final class Destination {
    var id: UUID = UUID()
    var name: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var isLocalUMKM: Bool = false
    var visitOrder: Int = 0 

    init(name: String, latitude: Double, longitude: Double, isLocalUMKM: Bool = false, visitOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isLocalUMKM = isLocalUMKM
        self.visitOrder = visitOrder
    }
}
