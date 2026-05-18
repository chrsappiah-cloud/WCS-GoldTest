//
//  WCS_GoldTestApp.swift
//  WCS-GoldTest
//
//  Created by Christopher Appiah-Thompson  on 18/5/2026.
//

import SwiftUI
import SwiftData

@main
struct WCS_GoldTestApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
