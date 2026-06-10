//
//  TripDetailTabView.swift
//  ALP_MAD
//
//  Created by Dharma on 04/06/26.
//


import SwiftUI
import SwiftData

struct TripDetailTabView: View {
    let trip: Trip
    
    @State private var activeTab: Int = 0
    
    @Environment(BudgetViewModel.self) private var vm
    
    var body: some View {
        TabView(selection: $activeTab) {
            // TAB 1: Itinerary Canvas / Days List
            TripDaysDetailView(trip: trip)
                .tabItem {
                    Label("Itinerary", systemImage: "map.fill")
                }
                .tag(0)
            
            // TAB 2: Budgeting Dashboard
            BudgetDetailView(trip: trip)
                .tabItem {
                    Label("Budget", systemImage: "creditcard.fill")
                }
                .tag(1)

            // TAB 3: Trip Journal
            TripJournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if activeTab == 1 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.showAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, BudgetItem.self, configurations: config)
    
    let dummyTrip = Trip(name: "Explore Bali", destination: "Bali", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 3))
    container.mainContext.insert(dummyTrip)
    
    return NavigationStack {
        TripDetailTabView(trip: dummyTrip)
    }
    .modelContainer(container)
    .environment(BudgetViewModel())
}
