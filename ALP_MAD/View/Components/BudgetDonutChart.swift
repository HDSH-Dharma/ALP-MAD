//
//  BudgetDonutChart.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI
import Charts

struct BudgetDonutChart: View {
    let breakdown: [CategoryBreakdownItem]
    let totalBudget: Double
    let currency: String
    let vm: BudgetViewModel
 
    var body: some View {
        ZStack {
            Chart(breakdown, id: \.category) { item in
                SectorMark(
                    angle: .value("Amount", item.total),
                    innerRadius: .ratio(0.60),
                    angularInset: 2
                )
                .foregroundStyle(item.category.swiftUIColor)
                .cornerRadius(4)
            }
            .frame(height: 220)
 
            VStack(spacing: 2) {
                Text("Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(vm.formatCurrency(totalBudget, currency: currency))
                    .font(.headline)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }
}
