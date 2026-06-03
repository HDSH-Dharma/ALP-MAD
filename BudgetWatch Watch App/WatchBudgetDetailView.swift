//
//  WatchBudgetDetailView.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI
import Foundation

struct WatchBudgetDetailView: View {
    let trip: WatchTripPayload
 
    private var totalBudget: Double {
        trip.items.reduce(0) { $0 + $1.amount }
    }
 
    private var breakdown: [(category: String, icon: String, color: Color, total: Double)] {
        var grouped: [String: Double] = [:]
        for item in trip.items {
            grouped[item.category, default: 0] += item.amount
        }
        return grouped
            .map { key, value in
                let cat = BudgetCategory(rawValue: key) ?? .other
                return (key, cat.icon, cat.watchColor, value)
            }
            .sorted { $0.total > $1.total }
    }
 
    private var duration: Int {
        Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0
    }
 
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
 
                // Total
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Est.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(totalBudget, currency: trip.currency))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.blue)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
 
                Divider()
 
                // Category breakdown
                ForEach(breakdown.prefix(5), id: \.category) { item in
                    HStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.system(size: 11))
                            .foregroundStyle(item.color)
                            .frame(width: 16)
                        Text(BudgetCategory(rawValue: item.category)?.shortName ?? item.category)
                            .font(.system(size: 12))
                            .lineLimit(1)
                        Spacer()
                        Text(formatCurrency(item.total, currency: trip.currency))
                            .font(.system(size: 12, weight: .medium))
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                }
 
                Divider()
 
                // Duration + dates
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text("\(duration) hari")
                        .font(.system(size: 11))
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(trip.destination)
        .navigationBarTitleDisplayMode(.inline)
    }
}


func formatCurrency(_ amount: Double, currency: String) -> String {
    let fmt = NumberFormatter()
    fmt.numberStyle           = .currency
    fmt.currencyCode          = currency
    fmt.maximumFractionDigits = currency == "IDR" ? 0 : 2
    fmt.maximumIntegerDigits  = 10
    return fmt.string(from: NSNumber(value: amount)) ?? "-"
}
