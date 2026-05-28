//
//  BudgetBarChart.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI
import Charts

struct BudgetBarChart: View {
    let breakdown: [(category: BudgetCategory, total: Double, percentage: Double)]
    let currency: String
    let vm: BudgetViewModel
 
    var body: some View {
        Chart(breakdown, id: \.category) { item in
            BarMark(
                x: .value("Category", item.category.rawValue),
                y: .value("Amount",   item.total)
            )
            .foregroundStyle(item.category.swiftUIColor)
            .cornerRadius(6)
            .annotation(position: .top) {
                Text(vm.formatCurrency(item.total, currency: currency))
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let str = value.as(String.self) {
                        Text(str)
                            .font(.system(size: 9))
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .frame(height: 200)
    }
}
