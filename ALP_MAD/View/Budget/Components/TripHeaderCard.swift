//
//  TripHeaderCard.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI

struct TripHeaderCard: View {
    let trip: Trip
    let vm: BudgetViewModel
 
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.destination)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(trip.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) – \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                    Text("·")
                    Text(vm.durationText(trip: trip))
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(vm.formatCurrency(vm.totalBudget(for: trip), currency: trip.currency))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                Text("estimated total")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
