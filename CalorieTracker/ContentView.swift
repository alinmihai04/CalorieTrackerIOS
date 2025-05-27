//
//  ContentView.swift
//  AAA
//
//  Created by Alin Mihai on 26.05.2025.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    // MARK: - State
    @State private var products: [Product] = []
    @State private var consumedProducts: [ConsumedProduct] = []
    @State private var showingDetails = false
    @State private var showingAddProduct = false
    @State private var showingAddConsumed = false
    @State private var consumedWaterQuantity = 0
    @State private var showingSettings = false
    let waterGoal = 3000
    @State private var waterStepInput = "250"

    // MARK: - Totals
    var totalCalories: Int {
        consumedProducts.reduce(0) { $0 + $1.calories }
    }
    
    var macroTotals: (protein: Double, carbs: Double, fat: Double) {
        consumedProducts.reduce((0, 0, 0)) {
            ($0.0 + $1.protein, $0.1 + $1.carbs, $0.2 + $1.fat)
        }
    }
    
    var waterStep: Int {
        return Int(waterStepInput) ?? 250
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                // Calorie Summary with Detail Button
                VStack(alignment: .leading, spacing: 20) {
                    // Calorie Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Calories")
                            .font(.title2)

                        Text("\(totalCalories) kcal / 2200 kcal")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.orange)

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green) // Protein
                                    .frame(width: 10, height: 10)
                                Text("P: 75g / 222g")
                                    .font(.caption)
                            }
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.blue) // Carbs
                                    .frame(width: 10, height: 10)
                                Text("C: 200g / 210g")
                                    .font(.caption)
                            }
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.pink) // Fat
                                    .frame(width: 10, height: 10)
                                Text("F: 60g / 70g")
                                    .font(.caption)
                            }
                        }
                        .padding(.top, 4)
                    }

                    // Water Intake Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Water Intake")
                            .font(.title2)

                        HStack {
                            Text("\(consumedWaterQuantity) ml / \(waterGoal) ml")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)

                            Spacer()

                            HStack(spacing: 12) {
                                // – Button
                                Button(action: {
                                    consumedWaterQuantity = max(0, consumedWaterQuantity - waterStep)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                }

                                // Step Input Field
                                TextField("", text: $waterStepInput)
                                    .keyboardType(.numberPad)
                                    .frame(width: 50)
                                    .multilineTextAlignment(.center)
                                    .padding(3)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                    .font(.subheadline)

                                // + Button
                                Button(action: {
                                    consumedWaterQuantity += waterStep
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 16)


                // Consumed Products List
                List {
                    Section(header: Text("Consumed Today")) {
                        ForEach(consumedProducts) { item in
                            VStack(alignment: .leading) {
                                Text(item.product.name)
                                    .font(.headline)
                                Text("\(Int(item.grams))g - \(item.calories) kcal")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onDelete(perform: deleteConsumed)
                        .onTapGesture(perform: editConsumed)
                    }
                }

                Spacer()

                // Buttons
//                HStack {
//                    Button {
//                        showingAddProduct = true
//                    } label: {
//                        Label("Add product", systemImage: "plus.circle")
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .padding(.horizontal, 16)
//                    .sheet(isPresented: $showingAddProduct) {
//                        AddProductView(products: $products)
//                    }
//                }
                
                HStack {
                    Button {
                        showingAddConsumed = true
                    } label: {
                        Label("Log product", systemImage: "plus.circle")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .sheet(isPresented: $showingAddConsumed) {
                        AddConsumedProductView(consumedProducts: $consumedProducts, products: $products)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .navigationTitle("Calorie Tracker")
            .navigationBarItems(trailing:
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                }
            )
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    struct SettingsView: View {
        @EnvironmentObject var settings: SettingsModel

        @State private var showingResetAlert = false
        @State private var selectedPreset: MacroPreset = .balanced

        var macroCalories: (protein: Int, carbs: Int, fat: Int) {
            let dist = selectedPreset.distribution
            return (
                protein: Int(Double(settings.calorieGoal) * dist.protein),
                carbs: Int(Double(settings.calorieGoal) * dist.carbs),
                fat: Int(Double(settings.calorieGoal) * dist.fat)
            )
        }

        var macroGrams: (protein: Int, carbs: Int, fat: Int) {
            let cal = macroCalories
            return (
                protein: cal.protein / 4,
                carbs: cal.carbs / 4,
                fat: cal.fat / 9
            )
        }
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Calorie & Water intake Goals")) {
                        Stepper("Calorie Goal: \(settings.calorieGoal) kcal", value: $settings.calorieGoal, in: 1000...5000, step: 50)
                        Stepper("Water Goal: \(settings.waterGoal) ml", value: $settings.waterGoal, in: 500...6000, step: 100)
                    }
                    
                    Section(header: Text("Macronutrient Split")) {
                        Picker("Preset", selection: $selectedPreset) {
                            ForEach(MacroPreset.allCases) { preset in
                                Text(preset.label).tag(preset)
                            }
                        }
                        .onChange(of: selectedPreset) { newPreset in
                            settings.macroPresetRaw = newPreset.rawValue
                        }
                        .pickerStyle(.menu)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories: \(settings.calorieGoal) kcal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("Protein: \(macroGrams.protein)g  •  \(selectedPreset.distribution.protein * 100, specifier: "%.0f")%")
                            Text("Carbs: \(macroGrams.carbs)g  •  \(selectedPreset.distribution.carbs * 100, specifier: "%.0f")%")
                            Text("Fat: \(macroGrams.fat)g  •  \(selectedPreset.distribution.fat * 100, specifier: "%.0f")%")
                        }
                        .font(.caption)
                    }

                    Section(header: Text("Manage")) {
                        NavigationLink(destination: EditProductsView()) {
                            Label("Edit Products", systemImage: "square.and.pencil")
                        }

                        NavigationLink(destination: EditProductsView()) {
                            Label("View History", systemImage: "chart.bar")
                        }
                    }

                    Section {
                        Button(role: .destructive) {
                            showingResetAlert = true
                        } label: {
                            Label("Reset All Data", systemImage: "trash")
                        }
                    }
                }
                .onAppear {
                    let preset = MacroPreset(rawValue: settings.macroPresetRaw) ?? .balanced
                    selectedPreset = preset
                }
                .navigationTitle("Settings")
                .alert("Reset All Data?", isPresented: $showingResetAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        settings.resetDefaults()
                    }
                }
            }
        }
    }

    
    struct EditProductsView: View {
        var body: some View {
            Text("Edit your products here")
                .navigationTitle("Edit Products")
        }
    }
    
    struct MacroView: View {
        let color: Color
        let label: String
        let current: Int
        let goal: Int
        
        var body: some View {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text("\(label): \(current)g / \(goal)g")
            }
        }
    }

    // MARK: - Helpers
    func deleteConsumed(at offsets: IndexSet) {
        consumedProducts.remove(atOffsets: offsets)
    }
    
    func editConsumed() {
        print("test edit consumed")
    }
}

// MARK: - Models
struct Product: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var kcalPer100g: Int
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
}

struct ConsumedProduct: Identifiable {
    var id = UUID()
    var product: Product
    var grams: Double

    var calories: Int {
        Int(Double(product.kcalPer100g) * grams / 100.0)
    }

    var protein: Double {
        product.proteinPer100g * grams / 100.0
    }

    var carbs: Double {
        product.carbsPer100g * grams / 100.0
    }

    var fat: Double {
        product.fatPer100g * grams / 100.0
    }
}

// MARK: - Calorie Detail View
struct CalorieDetailView: View {
    var protein: Double
    var carbs: Double
    var fat: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Macronutrient Breakdown")
                .font(.title)
                .padding(.bottom)

            Text("Protein: \(String(format: "%.1f", protein)) g")
            Text("Carbohydrates: \(String(format: "%.1f", carbs)) g")
            Text("Fat: \(String(format: "%.1f", fat)) g")

            Spacer()
        }
        .padding()
    }
}

// MARK: - Add Product View
struct AddProductView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var products: [Product]
    @State private var name = ""
    @State private var kcal = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Info")) {
                    TextField("Name", text: $name)
                    TextField("Calories / 100g", text: $kcal).keyboardType(.numberPad)
                    TextField("Protein / 100g", text: $protein).keyboardType(.decimalPad)
                    TextField("Carbs / 100g", text: $carbs).keyboardType(.decimalPad)
                    TextField("Fat / 100g", text: $fat).keyboardType(.decimalPad)
                }

                Button("Save") {
                    print("SAVE")
                    if let kcalInt = Int(kcal),
                       let proteinVal = Double(protein),
                       let carbsVal = Double(carbs),
                       let fatVal = Double(fat), !name.isEmpty {
                        let newProduct = Product(
                            name: name,
                            kcalPer100g: kcalInt,
                            proteinPer100g: proteinVal,
                            carbsPer100g: carbsVal,
                            fatPer100g: fatVal
                        )
                        products.append(newProduct)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Product")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

// MARK: - Add Consumed Product View
struct AddConsumedProductView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var consumedProducts: [ConsumedProduct]
    @Binding var products: [Product]
    @State private var selectedProduct: Product?
    @State private var grams = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Product")) {
                    Picker("Product", selection: $selectedProduct) {
                        ForEach(products, id: \.self) { product in
                            Text(product.name).tag(product as Product?)
                        }
                    }
                }

                Section(header: Text("Consumed Amount")) {
                    TextField("Grams", text: $grams)
                        .keyboardType(.decimalPad)
                }

                Button("Save") {
                    print("SAVE CONSUMED")
                    if let selected = selectedProduct,
                       let gramsVal = Double(grams) {
                        let consumed = ConsumedProduct(product: selected, grams: gramsVal)
                        consumedProducts.append(consumed)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Log Consumed")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

