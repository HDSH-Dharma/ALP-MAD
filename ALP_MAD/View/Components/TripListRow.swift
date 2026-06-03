//
//  TripListRow.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI
import SwiftData

struct TripListRow: View {
    @Environment(BudgetViewModel.self) private var vm
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.destination)
                        .font(.headline)
                    Text(trip.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(vm.formatCurrency(vm.totalBudget(for: trip), currency: trip.currency))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Text("\(trip.budgetItems.count) items")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            let breakdown = vm.categoryBreakdown(for: trip)
            if !breakdown.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(breakdown.prefix(4), id: \.category) { item in
                            HStack(spacing: 4) {
                                Image(systemName: item.category.icon)
                                    .font(.system(size: 10))
                                Text(item.category.rawValue)
                                    .font(.system(size: 10))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(item.category.swiftUIColor.opacity(0.15))
                            .foregroundStyle(item.category.swiftUIColor)
                            .clipShape(Capsule())
                        }
                    }
                }
            }

            HStack {
                Image(systemName: "calendar")
                    .font(.caption2)
                Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) – \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                Text("·")
                    .font(.caption2)
                Text(vm.durationText(trip: trip))
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
