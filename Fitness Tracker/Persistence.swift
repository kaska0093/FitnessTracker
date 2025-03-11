//
//  Persistence.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 19.02.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Exercises") // Имя модели
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("⚠️ Ошибка загрузки Core Data: \(error), \(error.userInfo)")
            }
        }
    }
}
