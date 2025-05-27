//
//  SettingsModel.swift
//  AAA
//
//  Created by Alin Mihai on 27.05.2025.
//

import SwiftUI
import Combine

class SettingsModel: ObservableObject {
    @AppStorage("calorieGoal") var calorieGoal: Int = 2200
    @AppStorage("proteinGoal") var proteinGoal: Int = 150
    @AppStorage("carbsGoal") var carbsGoal: Int = 200
    @AppStorage("fatGoal") var fatGoal: Int = 70
    @AppStorage("waterGoal") var waterGoal: Int = 3000
    @AppStorage("macroPreset") var macroPresetRaw: String = MacroPreset.balanced.rawValue

    var macroPreset: MacroPreset {
        get { MacroPreset(rawValue: macroPresetRaw) ?? .balanced }
        set { macroPresetRaw = newValue.rawValue }
    }

    func applyPreset(_ preset: MacroPreset) {
        macroPreset = preset
        let dist = preset.distribution
        proteinGoal = Int(Double(calorieGoal) * dist.protein) / 4
        carbsGoal = Int(Double(calorieGoal) * dist.carbs) / 4
        fatGoal = Int(Double(calorieGoal) * dist.fat) / 9
    }

    func resetDefaults() {
        calorieGoal = 2200
        proteinGoal = 150
        carbsGoal = 200
        fatGoal = 70
        waterGoal = 3000
        macroPreset = .balanced
    }
}
