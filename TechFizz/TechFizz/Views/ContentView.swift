//
//  ContentView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//


import SwiftUI


struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)
            
            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.circle")
                }
                .tag(3)
        }
    }
}


#Preview {
    ContentView()
}
