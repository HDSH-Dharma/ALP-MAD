//
//  WatchTripPayload.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//


import Foundation
import WatchConnectivity
 
// MARK: - Data format yang dikirim antar device
 
struct WatchTripPayload: Codable {
    let id: String
    let name: String
    let destination: String
    let startDate: Date
    let endDate: Date
    let currency: String
    let items: [WatchItemPayload]
}
 
struct WatchItemPayload: Codable {
    let id: String
    let title: String
    let amount: Double
    let category: String
    let note: String
}
 
// MARK: - WatchConnectivityManager
 
@Observable
final class WatchConnectivityManager: NSObject, WCSessionDelegate {
 
    static let shared = WatchConnectivityManager()
 
    // Watch side akan update ini setiap kali dapat data baru dari iPhone
    var receivedTrips: [WatchTripPayload] = []
 
    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
 
    // MARK: - iPhone → kirim ke Watch
 
    func sendTrips(_ trips: [Trip]) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
 
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else { return }
        #endif
 
        let payloads = trips.map { trip in
            WatchTripPayload(
                id:          trip.id.uuidString,
                name:        trip.name,
                destination: trip.destination,
                startDate:   trip.startDate,
                endDate:     trip.endDate,
                currency:    trip.currency,
                items:       trip.budgetItems.map { item in
                    WatchItemPayload(
                        id:       item.id.uuidString,
                        title:    item.title,
                        amount:   item.amount,
                        category: item.category.rawValue,
                        note:     item.note
                    )
                }
            )
        }
 
        guard let data = try? JSONEncoder().encode(payloads) else { return }
 
        // updateApplicationContext: Watch terima data ini
        try? WCSession.default.updateApplicationContext(["trips": data])
    }
 
    // MARK: - Watch → terima dari iPhone
 
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext["trips"] as? Data,
              let payloads = try? JSONDecoder().decode([WatchTripPayload].self, from: data)
        else { return }
 
        DispatchQueue.main.async {
            self.receivedTrips = payloads
        }
    }
 
    // MARK: - WCSessionDelegate required methods
 
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
 
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
