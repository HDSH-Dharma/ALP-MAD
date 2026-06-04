//
//  WatchBudgetDetailView.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI
import Charts

struct WatchBudgetDetailView: View {
    let trip: WatchTripPayload
 
    private var totalBudget: Double {
        trip.items.reduce(0) { $0 + $1.amount }
    }
 
    private var breakdown: [(category: String, icon: String, color: Color, total: Double, percentage: Double)] {
        var grouped: [String: Double] = [:]
        for item in trip.items {
            grouped[item.category, default: 0] += item.amount
        }
        let total = grouped.values.reduce(0, +)
        return grouped
            .map { key, value in
                // Now safely mapping to your actual BudgetCategory enum properties
                let cat = BudgetCategory(rawValue: key) ?? .other
                return (key, cat.icon, cat.watchColor, value, total > 0 ? value / total : 0)
            }
            .sorted { $0.total > $1.total }
    }
 
    private var duration: Int {
        Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0
    }
 
    var body: some View {
        List {
            // MARK: Summary Section
            Section {
                VStack(alignment: .center, spacing: 2) {
                    Text(trip.destination)
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text(formatCurrency(totalBudget, currency: trip.currency))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    Text("Total Estimasi")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)
            
            // MARK: Visual Chart Section
            if !breakdown.isEmpty {
                Section(header: Text("Alokasi Dana")) {
                    Chart(breakdown, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.total),
                            innerRadius: .ratio(0.65),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.color)
                    }
                    .frame(height: 100)
                    .padding(.vertical, 6)
                }
            }
            
            // MARK: Breakdown List Section
            Section(header: Text("Kategori")) {
                ForEach(breakdown, id: \.category) { item in
                    HStack(spacing: 8) {
                        Image(systemName: item.icon)
                            .font(.system(size: 11))
                            .foregroundStyle(item.color)
                            .frame(width: 16)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            // Uses your clean watch short names (e.g. "Stay", "Transport", "Food")
                            Text(BudgetCategory(rawValue: item.category)?.shortName ?? item.category)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                            Text("\(Int(item.percentage * 100))%")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(formatCurrency(item.total, currency: trip.currency))
                            .font(.system(size: 12, weight: .medium))
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 2)
                }
            }
            
            // MARK: Footer Info
            Section {
                HStack {
                    Label("\(duration) hari", systemImage: "calendar")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(trip.name)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Detail")
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
