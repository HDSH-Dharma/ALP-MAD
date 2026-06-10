//
//  JournalCards.swift
//  ALP_MAD
//
//  Created by student on 04/06/26.
//

import SwiftUI

struct JournalEntryRow: View {
    let entry: JournalEntry
    let vm: TripJournalViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let data = entry.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption2)
                Text(vm.formattedDate(entry.date))
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            Text(entry.title)
                .font(.headline)

            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
