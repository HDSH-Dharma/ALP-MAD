//
//  TripListView.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI
import SwiftData
import WatchConnectivity

struct TripListView: View {
    @Environment(\.modelContext) private var context
    @Environment(BudgetViewModel.self)  private var vm   // shared from app entry point
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(trips) { trip in
                            NavigationLink {
                                #if os(watchOS)
                                WatchBudgetDetailView(trip: trip)
                                #else
                                TripDetailTabView(trip: trip)
                                #endif
                            } label: {
                                TripListRow(trip: trip)
                            }
                        }
                    }
                    #if os(watchOS)
                    .listStyle(.plain)
                    #else
                    .listStyle(.insetGrouped)
                    #endif
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        vm.showAddTrip = true
                    } label: {
                        Label("New Trip", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: Bindable(vm).showAddTrip) {
                AddTripView()
                #if !os(watchOS)
                   .presentationDetents([.medium, .large])
                #endif
            }
            .onAppear {
                WatchConnectivityManager.shared.sendTrips(trips)
            }
            .onChange(of: trips) { _, newTrips in
                WatchConnectivityManager.shared.sendTrips(newTrips)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 64))
                .foregroundStyle(.blue.opacity(0.6))
            Text("Plan Your First Trip")
                .font(.title2)
                .fontWeight(.bold)
            Text("Create a trip and start estimating\nyour travel budget.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                vm.showAddTrip = true
            } label: {
                Label("Create Trip", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
