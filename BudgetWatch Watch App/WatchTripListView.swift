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
                    VStack(spacing: 12) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.system(size: 34))
                            .foregroundStyle(.blue)
                        Text("Open App in iPhone\nto sync trip.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
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
            .navigationTitle("My Trip")
        }
    }
}
