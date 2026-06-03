//
//  WatchTripListView.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI
import Foundation

struct WatchTripListView: View {
    private var wc: WatchConnectivityManager { .shared }
 
    var body: some View {
        NavigationStack {
            List {
                if wc.receivedTrips.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("Buka app di iPhone\nlalu tambah trip.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(wc.receivedTrips, id: \.id) { trip in
                        NavigationLink {
                            WatchBudgetDetailView(trip: trip)
                        } label: {
                            WatchTripRow(trip: trip)
                        }
                    }
                }
            }
            .navigationTitle("Trips")
        }
    }
}
