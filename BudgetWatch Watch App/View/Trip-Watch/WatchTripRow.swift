//
//  WatchTripRow.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI

struct WatchTripRow: View {
    let trip: WatchTripPayload
 
    private var calculatedTotal: Double {
        trip.items.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(trip.destination)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(trip.name)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(formatCurrency(calculatedTotal, currency: trip.currency))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.blue)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
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
