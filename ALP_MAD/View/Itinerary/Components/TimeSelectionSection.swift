//
//  TimeSelectionSection.swift
//  ALP_MAD
//
//  Created by Dharma on 11/06/26.
//

import SwiftUI
import SwiftData

struct TimeSelectionSection: View {
    @Binding var selectedTime: Date
    let errorMessage: String?
    
    var body: some View {
        Section("Waktu Kunjungan") {
            DatePicker(
                "Jam",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .tint(.themeTeal)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
