//
//  AddExerciseView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 14.03.2025.
//

import SwiftUI
import CoreData


struct AddExerciseView: View {
    let date: Date
    @Environment(\.managedObjectContext) private var viewContext  // ✅ Используем переданный контекст
    @StateObject private var viewModel = ExerciseViewModel()
    
    var body: some View {
        VStack {
            Text("Выберите упражнение")
                .font(.headline)
                .padding()
            
            List {
                ForEach(viewModel.exercises) { exercise in
                    Button(action: {
                        addExerciseToDay(exercise)
                    }) {
                        HStack {
                            Text(exercise.name ?? "Без названия")
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchExercises()
        }
    }
    
    func addExerciseToDay(_ exercise: ListOfExercises) {
        // ✅ Проверяем, что viewContext не nil
        guard let coordinator = viewContext.persistentStoreCoordinator else {
            print("⚠️ Ошибка: persistentStoreCoordinator == nil")
            return
        }

        let request: NSFetchRequest<TrainingDayEntity> = TrainingDayEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            let trainingDay: TrainingDayEntity
            
            if let existingDay = results.first {
                trainingDay = existingDay
            } else {
                trainingDay = TrainingDayEntity(context: viewContext)  // ✅ Создаём новый день
                trainingDay.date = date
            }
            
            let newExercise = ExerciseEntity(context: viewContext)
            newExercise.name = exercise.name
            newExercise.weight = 0.0
            newExercise.reps = 0
            newExercise.day = trainingDay  // ✅ Связываем упражнение с днём

            try viewContext.save()  // ✅ Сохраняем
        } catch {
            print("❌ Ошибка сохранения: \(error.localizedDescription)")
        }
    }
}
