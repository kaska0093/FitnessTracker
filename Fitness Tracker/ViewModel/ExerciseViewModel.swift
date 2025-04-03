//
//  ExerciseViewModel.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 19.02.2025.
//

//Проблема в вашем коде связана с тем, что @Environment(\.managedObjectContext) не работает в ExerciseViewModel, так как это свойство доступно только внутри View в SwiftUI, а не в обычных классах вроде ObservableObject. В вашем случае context в ExerciseViewModel остается nil, что и вызывает ошибку при попытке выполнить context.fetch(request).
//
//Чтобы исправить это, нужно передать NSManagedObjectContext в ExerciseViewModel явно, например, через инициализатор.

import SwiftUI
import CoreData

class ExerciseViewModel: ObservableObject {
    
    //@Environment(\.managedObjectContext) private var context
    private let context: NSManagedObjectContext


    @Published var exercises: [ListOfExercises] = []
    @Published var trainingDays: [TrainingDayEntity] = []

    // ✅ Теперь передаём `context` в `init()`
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchExercises()
        fetchTrainingDays()
    }
    
    
    //for tests
    func setContext(_ context: NSManagedObjectContext) {
        //self.context = context
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
    
    // Новый метод для добавления сета
        func addSet(to exercise: ExerciseEntity) {
            let newSet = SetEntity(context: context)
            newSet.id = UUID()
            newSet.weight = 0
            newSet.reps = 0
            newSet.exercise = exercise
            
            // Получаем текущий максимальный index и увеличиваем его
            let maxIndex = (exercise.sets as? Set<SetEntity>)?.max(by: { $0.index < $1.index })?.index ?? -1
            newSet.index = maxIndex + 1
            
            saveContext()
        }
    
    func deleteSet(for exercise: ExerciseEntity, at offsets: IndexSet) {
            // Получаем все сеты для упражнения
        for index in offsets {
            // Находим соответствующий объект SetEntity
            if let setToDelete = exercise.sets?.allObjects[index] as? SetEntity {
                // Удаляем объект из контекста
                context.delete(setToDelete)
                
                // Обновляем индексы оставшихся подходов
                let remainingSets = (exercise.sets as? Set<SetEntity> ?? []).sorted { $0.index < $1.index }
                for (newIndex, set) in remainingSets.enumerated() {
                    set.index = Int16(newIndex)
                }
                
            }
        }
        saveContext()
    }
    
    func deleteExerciseInCurrentDay(exercise: ExerciseEntity) {
        context.delete(exercise)
        saveContext()
    }
    
    func fetchTrainingDays() {
            // Здесь ваша логика получения данных из Core Data
            let request = TrainingDayEntity.fetchRequest()
            //request.sortDescriptors = [NSSortDescriptor(keyPath: \TrainingDayEntity.date, ascending: true)]
            
            do {
                let context = PersistenceController.shared.container.viewContext
                trainingDays = try context.fetch(request)
            } catch {
                print("Ошибка при загрузке training days: \(error)")
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
    func currentTrainingDay(for date: Date) -> TrainingDayEntity? {
            trainingDays.first { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date) }
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
            fetchTrainingDays()
        } catch {
            print("⚠️ Ошибка сохранения: \(error)")
        }
    }
}
extension ExerciseViewModel {
    
    struct ExerciseData: Codable {
        let id: UUID
        let name: String
        let descriptions: String
        let order: Int16
    }
    
    func loadExercisesFromJSON() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("❌ Файл exercises.json не найден")
            return
        }
        
//        let uuidString = "660e8400-e29b-41d4-a716-446655440001"
//        if let uuid = UUID(uuidString: uuidString) {
//            print("✅ Валидный UUID: \(uuid)")
//        } else {
//            print("❌ Некорректный UUID")
//        }
        
        do {
            let data = try Data(contentsOf: url)
            print("✅ Данные из файла успешно прочитаны, длина: \(data.count) байт")
            let jsonString = String(data: data, encoding: .utf8)
            print("JSON как строка: \(jsonString ?? "Ошибка декодирования строки")")
            let decoder = JSONDecoder()
            let exercises = try decoder.decode([ExerciseData].self, from: data)
            print("✅ Успешно декодировано \(exercises.count) упражнений")

            for exerciseData in exercises {
                let exerciseEntity = ListOfExercises(context: context)
                exerciseEntity.id = exerciseData.id
                exerciseEntity.name = exerciseData.name
                exerciseEntity.descriptions = exerciseData.descriptions
                exerciseEntity.order = exerciseData.order
            }
            
            try context.save()
            print("✅ Данные успешно загружены в Core Data")
            //viewModel.fetchExercises()
        } catch {
            print("❌ Ошибка загрузки JSON: \(error.localizedDescription)")
            print("Полная информация об ошибке: \(error)")
        }
    }
    
    func deleteAllTrainingDays() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TrainingDayEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            try context.save() // Сохраняем изменения
        } catch {
            print("Ошибка при удалении всех тренировочных дней: \(error)")
        }
        saveContext()
    }
}

extension ExerciseViewModel {   //CalendarGrid
    func createTrainingDay(for date: Date) -> TrainingDayEntity {
        let newTrainingDay = TrainingDayEntity(context: context)
        //print(newTrainingDay)
        newTrainingDay.date = date
        return newTrainingDay
    }
    
    func createSet(for exercise: ExerciseEntity, reps: Int16 = 10, weight: Double = 20.0, index: Int16? = nil) -> SetEntity {
        let newSet = SetEntity(context: context) // Создаём новый объект
        newSet.reps = reps
        newSet.weight = weight
        newSet.index = index ?? Int16((exercise.sets as? Set<SetEntity>)?.count ?? 0) // Сохраняем индекс
        newSet.isCompleted = false
        newSet.exercise = exercise
        return newSet
    }

    func createExercise(for trainingDay: TrainingDayEntity, from exercise: ExerciseEntity) -> ExerciseEntity {
        let newExercise = ExerciseEntity(context: context)
        newExercise.name = exercise.name
        newExercise.trainigDay = trainingDay

//        // Создаём новые подходы с сохранением порядка
//        let newSets = (exercise.sets as? Set<SetEntity> ?? [])
//            .sorted(by: { $0.index < $1.index })
//            .map { _ in createSet(for: newExercise) }
//
//        newExercise.sets = NSSet(array: newSets)
        return newExercise
    }
}

extension ExerciseViewModel {//AddExerciseView
    
    func addExerciseToDay(_ exercise: ListOfExercises, date: Date) {
        
//        // ✅ Проверяем, что viewContext не nil
//        guard let coordinator = context.persistentStoreCoordinator else {
//            print("⚠️ Ошибка: persistentStoreCoordinator == nil")
//            return
//        }

        let request: NSFetchRequest<TrainingDayEntity> = TrainingDayEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as CVarArg)
        
        do {
            let results = try context.fetch(request)
            let trainingDay: TrainingDayEntity
            
            if let existingDay = results.first {
                trainingDay = existingDay
            } else {
                trainingDay = TrainingDayEntity(context: context)  // ✅ Создаём новый день
                trainingDay.date = date
            }
            
            let newExercise = ExerciseEntity(context: context)
            newExercise.name = exercise.name
            newExercise.trainigDay = trainingDay  // ✅ Связываем упражнение с днём

            saveContext()
        } catch {
            print("❌ Ошибка сохранения: \(error.localizedDescription)")
        }
    }
}

