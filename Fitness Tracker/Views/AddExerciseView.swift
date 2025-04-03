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
    //@Environment(\.managedObjectContext) private var viewContext  // ✅ Используем переданный контекст
    @EnvironmentObject var viewModel: ExerciseViewModel  // ✅ Получаем из EnvironmentObject

    var body: some View {
        VStack {
            Text("Выберите упражнение")
                .font(.headline)
                .padding()
            
            List {
                ForEach(viewModel.exercises) { exercise in
                    Button(action: {
                        viewModel.addExerciseToDay(exercise, date: date)
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
//        .onAppear {
            //viewModel.fetchExercises()
//            viewModel.fetchTrainingDays()
//        }
        .onDisappear() {
            viewModel.fetchTrainingDays()
        }
    }
    

}
