//
//  ExerciseViewModel.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 19.02.2025.
//

import Foundation
import CoreData

class ExerciseViewModel: ObservableObject {
    
    private let context = PersistenceController.shared.container.viewContext

    @Published var exercises: [ExerciseEntity] = []

    init() {
        fetchExercises()
    }

    func fetchExercises() {
        let request: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)] // Сортировка по order
        do {
            exercises = try context.fetch(request)
        } catch {
            print("⚠️ Ошибка загрузки: \(error)")
        }
    }

    func addExercise(name: String, description: String) {
        let newExercise = ExerciseEntity(context: context)
        newExercise.name = name
        newExercise.descriptions = description
        newExercise.id = UUID() // Генерируем уникальный ID
        newExercise.order = Int16(exercises.count) // Устанавливаем порядок для нового элемента

        saveContext()
    }

    func deleteExercise(_ exercise: ExerciseEntity) {
        context.delete(exercise)
        saveContext()
    }

    func saveContext() {
        do {
            try context.save()
            fetchExercises()
        } catch {
            print("⚠️ Ошибка сохранения: \(error)")
        }
    }
}


