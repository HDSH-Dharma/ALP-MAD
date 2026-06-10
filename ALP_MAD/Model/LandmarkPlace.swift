//
// LandmarkPlace.swift
// ALP_MAD
//
// Created by student on 10/06/26.
//

import Foundation
import CoreLocation

struct LandmarkPlace: Identifiable, Equatable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let shortDesc: String
    let isUMKM: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        shortDesc: String,
        isUMKM: Bool
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.shortDesc = shortDesc
        self.isUMKM = isUMKM
    }
    
    static func == (lhs: LandmarkPlace, rhs: LandmarkPlace) -> Bool {
        return lhs.id == rhs.id
    }
}
