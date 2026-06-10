//
//  ALP_MADApp.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI
import SwiftData

@main
struct ALP_MADApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Trip.self, BudgetItem.self, Destination.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
     
    @State private var vm = BudgetViewModel()
     
    var body: some Scene {
        WindowGroup {
            TripListView()
                .environment(vm)
        }
        .modelContainer(sharedModelContainer)
    }
}
