//
//  SetListCardView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 27.03.2025.
//

import SwiftUI

struct SetListCardView: View {
    let set: SetEntity
    @ObservedObject var viewModel: ExerciseViewModel
    @State private var isCompleted: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) { // Теперь карточки будут вертикальными
            HStack {
                VStack(alignment: .leading) {
                    
                    //let _ = print("📌 weight в SetListCardView: \(set.weight)")
                    Text("Повторения: \(set.reps)")
                        .font(.subheadline)
                        .bold()
                    Text("Вес: \(set.weight, specifier: "%.2f") кг")
                        .font(.subheadline)
                }
                Spacer(minLength: 2)
                Toggle("", isOn: $isCompleted)
                    .labelsHidden()
                    .onChange(of: isCompleted) { newValue in
                        set.isCompleted = newValue
                        viewModel.saveContext()
                    }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Делаем ячейку на всю ширину
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .onAppear {
            isCompleted = set.isCompleted
        }
    }
}
