//
//  BudgetWatchApp.swift
//  BudgetWatch Watch App
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI

@main
struct BudgetWatch_Watch_AppApp: App {
    // The watch UI is fed by WatchConnectivity payloads, not a local
    // SwiftData store, so no ModelContainer is created here.
    @State private var vm = BudgetViewModel()

    var body: some Scene {
        WindowGroup {
            WatchTripListView()
                .environment(vm)
        }
    }
}
