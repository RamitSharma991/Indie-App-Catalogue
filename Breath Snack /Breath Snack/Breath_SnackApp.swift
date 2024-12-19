//
//  Breath_SnackApp.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import SwiftUI

@main
struct BreathSnackApp: App {
    @StateObject private var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(sessionManager)
        }
    }
}

