//
//  ContentView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 10/01/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showWelcome = true
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        MainTabView()
            .environmentObject(sessionManager)
            .fullScreenCover(isPresented: $showWelcome) {
                WelcomeView(isPresented: $showWelcome)
                    .environmentObject(sessionManager)
                    .preferredColorScheme(.light)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale),
                        removal: .opacity.combined(with: .scale)
                    ))
            }
    }
}
