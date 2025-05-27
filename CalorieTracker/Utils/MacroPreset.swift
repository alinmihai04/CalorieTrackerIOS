//
//  MacroPreset.swift
//  AAA
//
//  Created by Alin Mihai on 27.05.2025.
//

import Foundation

enum MacroPreset: String, CaseIterable, Identifiable {
    case balanced, highProtein, highCarb, keto
    var id: String { rawValue }

    var label: String {
        switch self {
        case .balanced: return "Balanced"
        case .highProtein: return "High-Protein"
        case .highCarb: return "High-Carb"
        case .keto: return "Keto (Low-Carb)"
        }
    }

    var distribution: (protein: Double, carbs: Double, fat: Double) {
        switch self {
        case .balanced: return (0.3, 0.4, 0.3)
        case .highProtein: return (0.4, 0.3, 0.3)
        case .highCarb: return (0.25, 0.55, 0.2)
        case .keto: return (0.25, 0.1, 0.65)
        }
    }
}
