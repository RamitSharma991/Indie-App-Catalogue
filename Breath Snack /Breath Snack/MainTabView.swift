//
//  MainTabView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        TabView {
            BreathView()
                .environmentObject(sessionManager)
                .tabItem {
                    Label("Breathe", systemImage: "wind")
                }
            
            CalendarView()
                .environmentObject(sessionManager)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
    }
}
