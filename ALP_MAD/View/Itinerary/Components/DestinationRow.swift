//
// DestinationRow.swift
// ALP_MAD
//
// Created by student on 10/06/26.
//

import SwiftUI

struct DestinationRow: View {
    let destination: Destination
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Time badge
                VStack {
                    Text(destination.timeString)
                        .font(.subheadline.bold())
                        .foregroundColor(.themeTeal)
                }
                .frame(width: 50)
                
                // Order number
                ZStack {
                    Circle()
                        .fill(Color.themeGold.opacity(0.2))
                        .frame(width: 28, height: 28)
                    Text("\(destination.visitOrder + 1)")
                        .font(.caption.bold())
                        .foregroundColor(.themeGold)
                }
                
                // Place info
                VStack(alignment: .leading, spacing: 2) {
                    Text(destination.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.themeDarkText)
                    if !destination.activityDesc.isEmpty {
                        Text(destination.activityDesc)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let dest = Destination(
        name: "Tugu Pahlawan",
        latitude: -7.2458,
        longitude: 112.7378,
        isLocalUMKM: false,
        visitOrder: 0,
        dayNumber: 1,
        timeString: "09:00",
        activityDesc: "Monumen bersejarah perjuangan pahlawan."
    )
    
    return DestinationRow(destination: dest) {
        print("Tapped")
    }
    .padding()
}
