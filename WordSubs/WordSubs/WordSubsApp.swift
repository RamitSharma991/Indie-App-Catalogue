//
//  WordSubsApp.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import SwiftUI

@main
struct WordSubsApp: App {
    @StateObject private var viewModel = PhraseViewModel()
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(viewModel)
        }
    }
}
