//
//  HomeView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 14.03.2025.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @State private var selectedTab = "Рабочий стол"
    
    let tabs = ["Рабочий стол", "Тренировки", "Диета", "Сон"]

    var body: some View {
        VStack {
            // Верхний заголовок
            HStack {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(.gray)

                Spacer()
                
                Text("Тренировки")
                    .font(.title)
                    .bold()
                
                Spacer()

                Image(systemName: "line.horizontal.3")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Горизонтальная полоса с вкладками
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(selectedTab == tab ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedTab == tab ? .white : .black)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)

            // Отображение разных экранов
            Spacer()
            if selectedTab == "Рабочий стол" {
                DashboardView()
            } else if selectedTab == "Тренировки" {
                ContentView()
            } else if selectedTab == "Диета" {
                CalendarView()
            } else if selectedTab == "Сон" {
                SleepView()
            }
            Spacer()
        }
    }
}


struct DashboardView: View {
    var body: some View {
        Text("📊 Рабочий стол")
            .font(.largeTitle)
            .bold()
    }
}

struct WorkoutsView: View {
    var body: some View {
        Text("💪 Тренировки")
            .font(.largeTitle)
            .bold()
    }
}

struct DietView: View {
    var body: some View {
        Text("🍏 Диета")
            .font(.largeTitle)
            .bold()
    }
}

struct SleepView: View {
    var body: some View {
        Text("😴 Сон")
            .font(.largeTitle)
            .bold()
    }
}


struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: TrainingDayEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TrainingDayEntity.date, ascending: true)]
    ) private var trainingDays: FetchedResults<TrainingDayEntity>

    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack {
                Text("Выберите дату тренировки")
                    .font(.headline)

                CalendarGrid(selectedDate: $selectedDate, trainingDays: trainingDays)

                NavigationLink(destination: WorkoutDetailView(date: selectedDate)) {
                    Text("Перейти к тренировке")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("График тренировок")
        }
    }
}

struct CalendarGrid: View {
    @State private var currentMonth: Date = Date()
    @Binding var selectedDate: Date
    let trainingDays: FetchedResults<TrainingDayEntity>

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
        trainingDays.contains { trainingDay in
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

struct WorkoutDetailView: View {
    let date: Date
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = ExerciseViewModel()
    @FetchRequest(entity: TrainingDayEntity.entity(), sortDescriptors: [])
    private var trainingDays: FetchedResults<TrainingDayEntity>
    
    private var currentTrainingDay: TrainingDayEntity? {
        trainingDays.first { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: date) }
    }
    
    var body: some View {
        VStack {
            Text("Тренировка на \(formattedDate(date))")
                .font(.headline)
                .padding()
            
            if let trainingDay = currentTrainingDay, let exercises = trainingDay.exercises as? Set<ExerciseEntity> {
                List {
                    ForEach(Array(exercises), id: \.self) { exercise in
                        VStack(alignment: .leading) {
                            Text(exercise.name ?? "Без названия")
                                .font(.headline)
                            Text("Вес: \(exercise.weight, specifier: "%.1f") кг, Повторений: \(exercise.reps)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
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
            
            Spacer()
        }
        .padding()
    }
    
    @State private var showAddExerciseSheet = false

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}


