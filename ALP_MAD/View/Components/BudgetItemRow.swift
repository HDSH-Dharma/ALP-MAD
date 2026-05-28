//
//  BudgetItemRow.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI

struct BudgetItemRow: View {
    let item: BudgetItem
    let currency: String
    let vm: BudgetViewModel
 
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(item.category.swiftUIColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: item.category.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(item.category.swiftUIColor)
            }
 
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text(item.category.rawValue)
                    .font(.caption2)
                    .foregroundStyle(item.category.swiftUIColor)
            }
 
            Spacer()
 
            Text(vm.formatCurrency(item.amount, currency: currency))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}
