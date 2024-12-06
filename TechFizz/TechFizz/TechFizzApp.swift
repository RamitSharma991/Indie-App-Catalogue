//
//  TechFizzApp.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import SwiftUI

@main
struct TechFizzApp: App {
    @StateObject private var dataController = DataController()
    @StateObject private var settingsManager = SettingsManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(settingsManager)
                .preferredColorScheme(settingsManager.isDarkMode ? .dark : .light)
        }
    }
}

