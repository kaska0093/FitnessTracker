//
//  ContentView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 19.02.2025.
//

import SwiftUI
import CoreData

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject private var viewModel = ExerciseViewModel() // Используем ViewModel
    @State private var selectedExercise: ExerciseEntity? // Для выбора упражнения
    @State private var showingEditSheet = false // Для отображения sheet
    @State private var showingAddSheet = false // Для показа добавления
    
    var body: some View {
        NavigationView {
            // List($viewModel.exercises, editActions: [.delete, .move]) { $exercise in
            List {
                ForEach(viewModel.exercises) { exercise in
                    VStack(alignment: .leading) {
                        Text(exercise.name ?? "Без наfзвания")
                            .font(.headline)
                        Text(exercise.descriptions ?? "Нет описания")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .onTapGesture {
                        selectedExercise = exercise
                        print("Выбрано упражнение: \(exercise.name ?? "nil")") // Отладка
                        print("Установлено selectedExercise: \(selectedExercise?.name ?? "nil")")

                    }
                }
                .onDelete(perform: deleteExercise)
                .onMove(perform: moveItem)
                .listStyle(.plain)
            }
            .navigationTitle("Упражнения")
            // Sheet для добавления
            .sheet(isPresented: $showingAddSheet) {
                EditExerciseView(viewModel: viewModel, exercise: nil, isEditing: false)
            }
            // Sheet для редактирования
            .sheet(item: $selectedExercise) { exercise in // Привязка к selectedExercise
                EditExerciseView(viewModel: viewModel, exercise: exercise, isEditing: true)
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {showingAddSheet = true }) { // Открываем sheet для добавления
                        Label("Добавить", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func addExercise() {
        viewModel.addExercise(name: "сми", description: "Классические приседания сммм no ровной спиной")
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        offsets.map { viewModel.exercises[$0] }.forEach { exercise in
            viewModel.deleteExercise(exercise)
        }
    }
    
    private func moveItem(from source: IndexSet, to destination: Int) {
        viewModel.exercises.move(fromOffsets: source, toOffset: destination)
        // Обновляем порядок
        for (index, exercise) in viewModel.exercises.enumerated() {
            exercise.order = Int16(index)
        }
        viewModel.saveContext() // Сохраняем изменения
    }
}



//#Preview {
//    ContentView()
//}

// Экран редактирования/добавления
struct EditExerciseView: View {
    
    @ObservedObject var viewModel: ExerciseViewModel
    let exercise: ExerciseEntity? // nil для добавления, иначе для редактирования
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
