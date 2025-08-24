//
//  ThirtyDayMeApp.swift
//  ThirtyDayMe
//
//  Created by Franklin Zhang on 8/23/25.
//

import SwiftUI
import SwiftData

@main
struct ThirtyDayMeApp: App {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Challenge.self,
            DailyProgress.self
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
        .modelContainer(ThirtyDayMeApp.sharedModelContainer)
    }
}
