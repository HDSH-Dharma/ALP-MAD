//
//  BudgetWatchApp.swift
//  BudgetWatch Watch App
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI
import SwiftData

@main
struct BudgetWatch_Watch_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Trip.self, BudgetItem.self])
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
            WatchTripListView()
                .environment(vm)
        }
        .modelContainer(sharedModelContainer)
    }
}
