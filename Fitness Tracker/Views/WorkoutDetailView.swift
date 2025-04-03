//
//  WorkoutDetailView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 15.03.2025.
//

import SwiftUI
import CoreData


//Ошибка Referencing initializer 'init(_:content:)' on 'ForEach' requires that 'NSObject' conform to 'RandomAccessCollection' возникает из-за того, что trainingDay.exercises имеет тип, который не соответствует требованиям ForEach. В SwiftUI ForEach ожидает коллекцию, реализующую протокол RandomAccessCollection (например, Array, Set и т.д.), а также элементы, которые соответствуют протоколу Identifiable.
//
//Судя по всему, exercises в TrainingDayEntity — это отношение (relationship) в Core Data, которое, скорее всего, определено как NSSet (или другой тип, унаследованный от NSObject), а не как массив ([ExerciseEntity]). NSSet не соответствует RandomAccessCollection, поэтому возникает ошибка.

struct WorkoutDetailView: View {
    let date: Date  // ✅ Передаём только дату
    @State private var showAddExerciseSheet = false

    @EnvironmentObject var viewModel: ExerciseViewModel
    

    var body: some View {
        VStack {
            Text("Тренировка на \(formattedDate(date))")
                .font(.title)
                .bold()
                //.padding()
            
            if let trainingDay = viewModel.currentTrainingDay(for: date),
               let exercisesSet = trainingDay.exercises {
            
                let exercises = exercisesSet.allObjects as! [ExerciseEntity] // Преобразуем в массив
                

                List {
                    ForEach(exercises) { exercise in
//
//                        ForEach(exercise.sets?.allObjects as? [SetEntity] ?? []) { set_weight in
//                            let _ = print("📌 exercise[i] в WorkoutDetailView: \(set_weight.weight)")
//                        }
//                        ForEach(Array((exercise.sets as? Set<SetEntity> ?? []).sorted { $0.index < $1.index }), id: \.self)  { set_weight in
//                            let _ = print("📌 exercise[i] в WorkoutDetailView set_weight: \(set_weight.weight)")
//                        }
                        
                        //TODO: вот тут ошибка
                        // СКОпированные дни выдают 2 print / оригинал 4
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
//                          Section(header: Text(exercise.name ?? "Без названия").font(.headline)) {
                            VStack(alignment: .leading, spacing: 8) {
                                       Text(exercise.name ?? "Без названия")
                                           .font(.headline)
                                           .bold()
                                           .frame(maxWidth: .infinity, alignment: .leading) // Заголовок по центру
                                           .padding(.vertical, 2)
                                //Divider() // Разделительная линия
                                ForEach(Array((exercise.sets as? Set<SetEntity> ?? []).sorted { $0.index < $1.index }), id: \.self) { set in
                                    //let _ = print("📌 weight в WorkoutDetailView перед вызовом SetListCardView: \(set.weight)")
                                           SetListCardView(set: set, viewModel: viewModel)
                                               .listRowInsets(EdgeInsets())
                                               .listRowBackground(Color.clear)
                                       }
                                   }
                                   .padding(.vertical, 2)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let exerciseToDelete = exercises[index] // Теперь берем напрямую из FetchResults
                            viewModel.deleteExerciseInCurrentDay(exercise: exerciseToDelete)
                        }
                    }
                }

            } else {
                Text("Нет упражнений на этот день")
                    .foregroundColor(.gray)
                    .padding()
            }
                        Button("Добавить упражнение") {
                            showAddExerciseSheet.toggle()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .sheet(isPresented: $showAddExerciseSheet) {
                            AddExerciseView(date: date)
                        }
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return date.map { formatter.string(from: $0) } ?? "Неизвестная дата"
    }

}

