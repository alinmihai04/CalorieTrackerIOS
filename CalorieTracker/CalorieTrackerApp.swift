//
//  AAAApp.swift
//  AAA
//
//  Created by Alin Mihai on 26.05.2025.
//

import SwiftUI

@main
struct CalorieTrackerApp: App {
    @StateObject private var settings = SettingsModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(settings)
        }
    }
}
