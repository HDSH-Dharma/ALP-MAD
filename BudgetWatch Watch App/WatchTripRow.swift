//
//  WatchTripRow.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI

struct WatchTripRow: View {
    let trip: WatchTripPayload
 
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(trip.destination)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
            Text(formatCurrency(trip.items.reduce(0) { $0 + $1.amount }, currency: trip.currency))
                .font(.system(size: 12))
                .foregroundStyle(.blue)
        }
    }
    
    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle           = .currency
        fmt.currencyCode          = currency
        fmt.maximumFractionDigits = currency == "IDR" ? 0 : 2
        fmt.maximumIntegerDigits  = 10
        return fmt.string(from: NSNumber(value: amount)) ?? "-"
    }
}
