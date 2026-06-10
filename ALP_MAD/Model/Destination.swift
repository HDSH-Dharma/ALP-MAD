//
//  Destination.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation
import SwiftData
import MapKit

@Model
final class Destination {
    var id: UUID = UUID()
    var name: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var isLocalUMKM: Bool = false
    var visitOrder: Int = 0
    var dayNumber: Int = 1
    var timeString: String = ""
    var activityDesc: String = ""
    
    init(name: String, latitude: Double, longitude: Double, isLocalUMKM: Bool = false, visitOrder: Int = 0, dayNumber: Int = 1, timeString: String = "09:00", activityDesc: String = "") {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isLocalUMKM = isLocalUMKM
        self.visitOrder = visitOrder
        self.dayNumber = dayNumber
        self.timeString = timeString
        self.activityDesc = activityDesc
    }
}

extension Destination {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
