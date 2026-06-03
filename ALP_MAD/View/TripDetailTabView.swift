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
    
    var body: some View {
        TabView {
            // TAB 1: Itinerary Canvas / Days List
            TripDaysDetailView(trip: trip)
                .tabItem {
                    Label("Itinerary", systemImage: "map.fill")
                }
            
            // TAB 2: Budgeting Dashboard
            BudgetDetailView(trip: trip)
                .tabItem {
                    Label("Budget", systemImage: "creditcard.fill")
                }
        }
        // Tint color for active tab items (adjust to your project's custom asset themes)
        .accentColor(.blue) 
        // Hides the automatic back button item title if needed, letting the child view manage it
        .navigationBarTitleDisplayMode(.inline)
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
