//
//  EditExerciseView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 19.03.2025.
//

import SwiftUI

// Экран редактирования/добавления общего списка упражнений
struct EditExerciseView: View {
    
    @ObservedObject var viewModel: ExerciseViewModel
    let exercise: ListOfExercises? // nil для добавления, иначе для редактирования
    let isEditing: Bool // Флаг для определения режима
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var descriptions: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $name)
                TextField("Описание", text: $descriptions)
            }
            .navigationTitle(isEditing ? "Редактировать упражнение" : "Добавить упражнение")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if isEditing, let exercise = exercise {
                            // Режим редактирования
                            exercise.name = name
                            exercise.descriptions = descriptions
                        } else {
                            // Режим добавления
                            viewModel.addExercise(name: name, description: descriptions)
                        }
                        viewModel.saveContext() // Сохраняем изменения
                        dismiss()
                    }
                    .disabled(name.isEmpty) // Отключаем кнопку, если название пустое
                }
            }
            .onAppear {
                // Если редактируем, загружаем текущие данные
                if isEditing, let exercise = exercise {
                    name = exercise.name ?? ""
                    descriptions = exercise.descriptions ?? ""
                    print("Загружено в EditExerciseView: name=\(name), descriptions=\(descriptions)")
                }
            }
        }
    }
}

