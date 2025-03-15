//
//  ExerciseViewModel.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 19.02.2025.
//

import Foundation
import CoreData

class ExerciseViewModel: ObservableObject {
    
    private var context = PersistenceController.shared.container.viewContext

    @Published var exercises: [ListOfExercises] = []

    init() {
        fetchExercises()
    }
    
    func setContext(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchExercises() {
        let request: NSFetchRequest<ListOfExercises> = ListOfExercises.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)] // Сортировка по order
        do {
            exercises = try context.fetch(request)
        } catch {
            print("⚠️ Ошибка загрузки: \(error)")
        }
    }
    
    func fetchExercises(for date: Date) -> [ExerciseEntity] {
        let request: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "day.date == %@", date as CVarArg)

        do {
            return try context.fetch(request)
        } catch {
            print("Ошибка загрузки упражнений на дату: \(error.localizedDescription)")
            return []
        }
    }

    func addExercise(name: String, description: String) {
        let newExercise = ListOfExercises(context: context)
        newExercise.name = name
        newExercise.descriptions = description
        newExercise.id = UUID() // Генерируем уникальный ID
        newExercise.order = Int16(exercises.count) // Устанавливаем порядок для нового элемента

        saveContext()
    }

    func deleteExercise(_ exercise: ListOfExercises) {
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


