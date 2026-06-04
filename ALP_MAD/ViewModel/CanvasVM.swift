//
//  CanvasVM.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation
internal import Combine

class CanvasVM: ObservableObject {
    @Published var canvas: [ItineraryCanvas] = []
    
    init(canvas: [ItineraryCanvas]) {
        self.canvas = canvas
    }
    
    func addCanvas(_ canvas: ItineraryCanvas) {
        self.canvas.append(canvas)
    }
    
    func getCanvas() -> [ItineraryCanvas] {
        return canvas
    }
    
    func addLocations(_ locations: [ItineraryCanvas]) {
        self.canvas.append(contentsOf: locations)
    }
}
