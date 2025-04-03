//
//  ExerciseDetailView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 15.03.2025.
//

import SwiftUI

struct ExerciseDetailView: View {
    @ObservedObject var exercise: ExerciseEntity
    @EnvironmentObject var viewModel: ExerciseViewModel


    var body: some View {
        VStack {
            Text(exercise.name ?? "Упражнение")
                .font(.title)
                .bold()
                .padding()
            List {
                ForEach(
                    //(exercise.sets?.allObjects as? [SetEntity] ?? []).sorted { $0.index < $1.index }, // Сортируем по index
                    Array(exercise.sets as? Set<SetEntity> ?? []).sorted { $0.index < $1.index },
                    //MARK: разобраться почему это так!!!
                    //id: \.id
                    id: \.self
                ) { set in
                    let _ = print("📌 weight в ExerciseDetailView: \(set.weight)")
                    SetCardView(set: set)
                }
                .onDelete(perform: { offsets in
                    viewModel.deleteSet(for: exercise, at: offsets)
                })
            }

            Button(action: {
                viewModel.addSet(to: exercise) // Вызов метода внутри замыкания
            }) {
                Label("Добавить подход", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}
