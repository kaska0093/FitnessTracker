//
//  Fitness_TrackerTests.swift
//  Fitness TrackerTests
//
//  Created by Nikita Shestakov on 14.03.2025.
//

import XCTest
import CoreData
@testable import Fitness_Tracker

final class ExerciseViewModelTests: XCTestCase {
    
    var viewModel: ExerciseViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Используем временный in-memory контейнер для тестов
        let container = NSPersistentContainer(name: "Exercises")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Ошибка инициализации in-memory хранилища: \(error)")
            }
        }
        
        context = container.viewContext
        viewModel = ExerciseViewModel()
        viewModel.setContext(context) // Добавим метод setContext в ExerciseViewModel
    }
    
    override func tearDown() {
        context = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testAddExercise() {
        viewModel.addExercise(name: "Приседания", description: "Классические приседания")
        XCTAssertEqual(viewModel.exercises.count, 1, "Упражнение должно быть добавлено")
        XCTAssertEqual(viewModel.exercises.first?.name, "Приседания")
    }
    
    func testDeleteExercise() {
        let exercise = ExerciseEntity(context: context)
        exercise.name = "Отжимания"
        viewModel.exercises.append(exercise)
        
        viewModel.deleteExercise(exercise)
        XCTAssertTrue(viewModel.exercises.isEmpty, "Упражнение должно быть удалено")
    }
    
    func testFetchExercises() {
        let exercise1 = ExerciseEntity(context: context)
        exercise1.name = "Бег"
        let exercise2 = ExerciseEntity(context: context)
        exercise2.name = "Прыжки"
        
        try? context.save()
        
        viewModel.fetchExercises()
        XCTAssertEqual(viewModel.exercises.count, 2, "Должно загрузиться 2 упражнения")
        //XCTAssertEqual(viewModel.exercises.first?.name, "Прыжки")
    }
}
