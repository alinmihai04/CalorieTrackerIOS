//
//  Product.swift
//  AAA
//
//  Created by Alin Mihai on 26.05.2025.
//

import Foundation


struct sProduct: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var kcalPer100g: Int
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
}

struct sConsumedProduct: Identifiable {
    var id = UUID()
    var product: sProduct
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
