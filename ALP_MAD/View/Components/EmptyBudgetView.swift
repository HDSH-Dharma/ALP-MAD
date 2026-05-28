//
//  EmptyBudgetView.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI

struct EmptyBudgetView: View {
    let action: () -> Void
 
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
            Text("No Budget Items Yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Start by adding your estimated expenses\nfor each category.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: action) {
                Label("Add First Item", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}
