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
    //@Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: ExerciseViewModel


    //@StateObject private var viewModel = ExerciseViewModel()
    let tabs = ["Рабочий стол", "Упражнения", "Календарь", "Сон"]
    

    

    
    func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Подтвердите удаление",
                                      message: "Вы уверены, что хотите удалить все тренировки? Это действие невозможно отменить.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
            viewModel.deleteAllTrainingDays()
        }))
        
        // Получаем rootViewController через UIWindowScene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootController = windowScene.windows.first?.rootViewController {
                rootController.present(alert, animated: true, completion: nil)
            }
        }
    }
    

    
    var body: some View {
        @Environment(\.managedObjectContext) var viewContext  // <-- добавляем
        //var viewContextt = PersistenceController.shared.container.viewContext

        VStack {
            // Верхний заголовок
            HStack {
                Button(action: {
                    handleButtonAction()
                }) {
                    Image(systemName: buttonIcon())
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                Spacer()
                
                Text(headerTitle())
                    .font(.title)
                    .bold()

                
                Spacer()
                
                menuForCurrentTab()



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
            selectedView()
//            if selectedTab == "Рабочий стол" {
//                DashboardView()
//            } else if selectedTab == "Упражнения" {
//                ContentView()
//            } else if selectedTab == "Календарь" {
//                CalendarView()
//            } else if selectedTab == "Сон" {
//                SleepView()
//            }
            Spacer()
        }
    }
}

extension HomeView {
    // MARK: - Динамический заголовок
       func headerTitle() -> String {
           switch selectedTab {
           case "Упражнения": return "Мои упражнения"
           case "Календарь": return "Календарь тренировок"
           case "Сон": return "Анализ сна"
           default: return "Тренировки"
           }
       }

       // MARK: - Динамическая иконка для кнопки
       func buttonIcon() -> String {
           switch selectedTab {
           case "Упражнения": return "plus"  // Кнопка добавления упражнения
           case "Календарь": return "calendar.badge.plus" // Добавить тренировку
           case "Сон": return "moon.zzz"  // Анализ сна
           default: return "clock"
           }
       }

       // MARK: - Динамическое действие кнопки
       func handleButtonAction() {
           switch selectedTab {
           case "Упражнения":
               print("Добавление нового упражнения")
           case "Календарь":
               print("Добавление тренировки в календарь")
           case "Сон":
               print("Открытие анализа сна")
           default:
               print("Открытие истории тренировок")
           }
       }
    

       // MARK: - Динамическое меню
       @ViewBuilder
       func menuForCurrentTab() -> some View {
           Menu {
               switch selectedTab {
               case "Упражнения":
                   Button(action: { viewModel.loadExercisesFromJSON() } ) {
                       Label("Загрузить базовые упражнения", systemImage: "person")
                   }
               case "Календарь":
                   Button(action: {
                       showDeleteConfirmation()
                   }) {
                       Text("Удалить все тренировки")
                           .padding()
                           .background(Color.red)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                   }
               case "Сон":
                   Button(action: { print("Настройки сна") }) {
                       Label("Настройки сна", systemImage: "gearshape")
                   }
               default:
                   Button(action: { print("Выход") }) {
                       Label("Выход", systemImage: "arrow.right.circle")
                   }
               }
           } label: {
               Image(systemName: "line.horizontal.3")
                   .imageScale(.large)
                   .padding()
           }
       }

       // MARK: - Выбор отображаемого экрана
       @ViewBuilder
       func selectedView() -> some View {
           switch selectedTab {
           case "Упражнения": ContentView()
           case "Календарь": CalendarView()
           case "Сон": SleepView()
           default: DashboardView()
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


struct SleepView: View {
    var body: some View {
        Text("😴 Сон")
            .font(.largeTitle)
            .bold()
    }
}






