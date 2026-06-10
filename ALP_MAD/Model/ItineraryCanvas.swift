//
//  ItineraryCanvas.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation

struct ItineraryCanvas: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let locations: [String]
}
