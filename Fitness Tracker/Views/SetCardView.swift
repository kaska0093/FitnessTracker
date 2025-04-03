//
//  SetCardView.swift
//  Fitness Tracker
//
//  Created by Nikita Shestakov on 15.03.2025.
//

import SwiftUI
import CoreData

//TODO: привязать надо к ViewModel
struct SetCardView: View {
    @ObservedObject var set: SetEntity
    //@Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: ExerciseViewModel

    
    var body: some View {
        let _ = print("📌 weight в SetCardView где picker: \(set.weight)")
        VStack {
            HStack {
                Spacer()
                //Text("Вес: \(set.weight, specifier: "%.2f") кг")
                TextField("Вес (кг)", value: Binding(
                                                get: { set.weight },
                                                set: { newValue in
                                                    let weight = max(0, min(500.75, newValue)) // Ограничение 0–500.75
                                                    set.weight = weight
                                                }
                                            ), format: .number)
                                            .keyboardType(.decimalPad) // Числовая клавиатура с точкой
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 100)
                                            .multilineTextAlignment(.center)
                                            .toolbar {
                                                ToolbarItemGroup(placement: .keyboard) {
                                                    //Spacer() // Выравнивание кнопки справа
                                                    Button("Done") {
                                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                    }
                                                }
                                            }
                Spacer()
                Text("Повторения: \(set.reps)")
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.2)))
            
            HStack {
                // Два Picker для веса
                                        Picker("Кг", selection: Binding(
                                            get: { Int(set.weight) }, // Целая часть (килограммы)
                                            set: { newKg in
                                                let grams = set.weight - Double(Int(set.weight)) // Сохраняем дробную часть
                                                set.weight = Double(newKg) + grams // Обновляем вес
                                            }
                                        )) {
                                            ForEach(0...500, id: \.self) { kg in
                                                Text("\(kg) кг").tag(kg)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 100, height: 100)
                
                Picker("г", selection: Binding(
                                            get: { Int((set.weight - Double(Int(set.weight))) * 1000) }, // Дробная часть в граммах
                                            set: { newGrams in
                                                let kg = Double(Int(set.weight)) // Сохраняем целую часть
                                                set.weight = kg + Double(newGrams) / 1000 // Обновляем вес
                                            }
                                        )) {
                                            ForEach([0, 250, 500, 750], id: \.self) { grams in
                                                Text("\(grams) г").tag(grams)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 100, height: 100)
                                        
                                        Spacer()
                

                
                Stepper("Повторения", value: Binding(get: { set.reps }, set: { set.reps = $0 }))
                    .frame(width: 150)
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding()
        .onDisappear {
            viewModel.saveContext()
        }
    }
}
