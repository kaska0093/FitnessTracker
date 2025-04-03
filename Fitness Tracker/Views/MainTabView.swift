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


struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }

            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Статистика")
                }
        }
    }
}

struct StatsView: View {
    
    var body: some View {
        VStack {
            Text("📊 Статистика")
                .font(.largeTitle)
                .bold()
                .padding()

            Text("Здесь будут графики и данные о тренировках!")
                .foregroundColor(.gray)
                .padding()
        }
    }
}
//#Preview {
//    ContentView()
//}
