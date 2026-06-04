//
//  LandmarkPlace.swift
//  ALP_MAD
//
//  Created by student on 04/06/26.
//

import Foundation

struct LandmarkPlace: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let shortDesc: String
    let isUMKM: Bool
}
