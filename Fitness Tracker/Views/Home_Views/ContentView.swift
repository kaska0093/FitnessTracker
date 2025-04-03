//
//  ContentView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 14.03.2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: ExerciseViewModel  // ✅ Получаем из EnvironmentObject
    @State private var selectedExercise: ListOfExercises? // Для выбора упражнения
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
