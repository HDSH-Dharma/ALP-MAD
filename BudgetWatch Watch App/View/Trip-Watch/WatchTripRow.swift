//
//  WatchTripRow.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI

struct WatchTripRow: View {
    @Environment(BudgetViewModel.self) private var vm

    let trip: WatchTripPayload

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

            Text(vm.formatCurrency(vm.totalBudget(for: trip), currency: trip.currency))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.blue)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }
}
