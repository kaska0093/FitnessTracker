//
//  CalendarView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 15.03.2025.
//

import SwiftUI
import CoreData


struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: ExerciseViewModel
//    @FetchRequest(
//        entity: TrainingDayEntity.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \TrainingDayEntity.date, ascending: true)]
//    ) private var trainingDays: FetchedResults<TrainingDayEntity>

    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack {
                Text("Выберите дату тренировки")
                    .font(.headline)

                CalendarGrid(selectedDate: $selectedDate)

                    NavigationLink(destination: WorkoutDetailView(date: selectedDate)) {
                        Text("Перейти к тренировке")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                
            }
            //.navigationTitle("График тренировок")
        }
    }
}

struct CalendarGrid: View {
    @State private var currentMonth: Date = Date()
    @Binding var selectedDate: Date
    @EnvironmentObject var viewModel: ExerciseViewModel
    
    //---
    
    @State private var copiedWorkout: [ExerciseEntity]? = nil
    @State private var showCopiedAlert = false
    
    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack {
            // Навигация по месяцам
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .padding()
                }

                Text(currentMonthFormatted())
                    .font(.title2)
                    .fontWeight(.bold)

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            }
            .padding(.vertical)

            // 📅 Грид с днями
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { day in
                    if let date = day {
                        Button(action: {
                            selectedDate = date
                        }) {
                            Text("\(calendar.component(.day, from: date))")
                                .frame(width: 40, height: 40)
                                .background(getBackgroundColor(for: date)) // ✅ Фон зависит от условий
                                .clipShape(Circle())
                                .foregroundColor(getTextColor(for: date)) // ✅ Цвет текста
                        }
                        .contextMenu {
                            if isTrainingDay(date) {
                                Button(action: {
                                    copyWorkout(from: date)
                                }) {
                                    Label("Копировать тренировку", systemImage: "doc.on.doc")
                                }
                            }
                            //TODO: - проверка на то есть ли тренировка в буфере
                            Button(action: {
                                pasteWorkout(to: date)
                            }) {
                                Label("Вставить тренировку", systemImage: "arrow.down.doc")
                            }
                        }
                        .alert(isPresented: $showCopiedAlert) {
                            Alert(title: Text("Успех!"), message: Text("Тренировка скопирована."), dismissButton: .default(Text("ОК")))
                        }
                    } else {
                        Text("")
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .padding()
            .background(Color.white) // ✅ Белый фон для всего календаря
            .cornerRadius(15) // ✅ Закругляем углы
            .shadow(radius: 5) // ✅ Лёгкая тень для красоты
        }
    }

    // 📌 Функция смены месяца
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    // 📌 Форматирование месяца (например, "Март 2025")
    private func currentMonthFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: currentMonth).capitalized
    }

    // 📌 Получаем список дней месяца
    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return [] }
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        days += range.map { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
        }

        return days
    }

    // 📌 Проверяем, есть ли тренировка в этот день
    private func isTrainingDay(_ date: Date) -> Bool {
        viewModel.trainingDays.contains { trainingDay in
            if let trainingDate = trainingDay.date {
                return calendar.isDate(trainingDate, inSameDayAs: date)
            }
            return false
        }
    }

    // 📌 Определяем цвет фона для дня
    private func getBackgroundColor(for date: Date) -> Color {
        if calendar.isDate(selectedDate, inSameDayAs: date) {
            return Color.blue.opacity(0.8) // ✅ Синий фон для выбранного дня
        } else if isTrainingDay(date) {
            return Color.green.opacity(0.8) // ✅ Зелёный фон для тренировочных дней
        } else {
            return Color.clear // Остальные дни без фона
        }
    }

    // 📌 Определяем цвет текста для дня
    private func getTextColor(for date: Date) -> Color {
        return (calendar.isDate(selectedDate, inSameDayAs: date) || isTrainingDay(date)) ? .white : .black
    }
}

extension CalendarGrid {
    
    private func copyWorkout(from date: Date) {
        if let trainingDay = viewModel.trainingDays.first(where: { calendar.isDate($0.date ?? Date(), inSameDayAs: date) }) {
            copiedWorkout = trainingDay.exercises?.allObjects as? [ExerciseEntity]
            
            
            
            
            for i in copiedWorkout! {
                for y in i.sets?.allObjects as? [SetEntity] ?? [] {
                    print("\(y.weight)------copyWorkout")
                }
            }
            
            
            showCopiedAlert = true
        }
    }
    private func pasteWorkout(to date: Date) {
        guard let copiedWorkout = copiedWorkout else { return }

        let newTrainingDay = viewModel.createTrainingDay(for: date)

        for exercise in copiedWorkout {
            let newExercise = viewModel.createExercise(for: newTrainingDay, from: exercise)

            // Создаём новые подходы и привязываем их правильно
            let newSets = exercise.sets?.allObjects as? [SetEntity] ?? []
            let sortedSets = newSets.sorted(by: { $0.index < $1.index }) // Сортировка по индексу

            var copiedSets: [SetEntity] = []
            for oldSet in sortedSets {
                print("📌 weight в extension CalendarGrid : \(oldSet.weight)")

                let newSet = viewModel.createSet(
                    for: newExercise,
                    reps: oldSet.reps,
                    weight: oldSet.weight,
                    index: oldSet.index
                )
                copiedSets.append(newSet)
            }

            // Присваиваем массив копий, а не ссылку на старые объекты
            newExercise.sets = NSSet(array: copiedSets)
        }

        viewModel.saveContext()
    }

//    private func pasteWorkout(to date: Date) {
//        guard let copiedWorkout = copiedWorkout else { return }
//
//        let newTrainingDay = viewModel.createTrainingDay(for: date)
//
//        for exercise in copiedWorkout {
//            let newExercise = viewModel.createExercise(for: newTrainingDay, from: exercise)
//            newExercise.trainigDay = newTrainingDay
//        }
//        viewModel.saveContext()
//    }
}
