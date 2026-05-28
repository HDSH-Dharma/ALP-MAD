//
//  CategoryLegendRow.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI

struct CategoryLegendRow: View {
    let item: (category: BudgetCategory, total: Double, percentage: Double)
    let currency: String
    let vm: BudgetViewModel
 
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(item.category.swiftUIColor)
                .frame(width: 12, height: 12)
 
            Image(systemName: item.category.icon)
                .font(.caption)
                .foregroundStyle(item.category.swiftUIColor)
 
            Text(item.category.rawValue)
                .font(.subheadline)
 
            Spacer()
 
            VStack(alignment: .trailing, spacing: 2) {
                Text(vm.formatCurrency(item.total, currency: currency))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(Int(item.percentage * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
