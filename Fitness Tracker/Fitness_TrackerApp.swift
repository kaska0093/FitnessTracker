//
//  Fitness_TrackerApp.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 19.02.2025.
//

import SwiftUI

//
@main
struct Fitness_TrackerApp: App {
    let persistenceController = PersistenceController.shared.container.viewContext
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController)  // ✅ Передаём контекст
        }
    }
}
