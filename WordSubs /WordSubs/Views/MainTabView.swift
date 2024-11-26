//
//  MainTabView.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var viewModel: PhraseViewModel
    @AppStorage("isSignedIn") private var isSignedIn = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(0)
            
            BookmarksView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                }
                .tag(1)
                .badge(viewModel.getBookmarkedPhrases().count)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.circle.fill")
                }
                .tag(2)
                .badge(isSignedIn ? nil : "!")
        }
        .onChange(of: selectedTab) { newValue, oldValue in
            // Perform any necessary updates when switching tabs
            if newValue == 0 {
                // Refresh word of the day when returning to Learn tab
                viewModel.checkAndUpdateWordOfDay()
            } else if newValue == 1 {
                // Refresh bookmarks when switching to Bookmarks tab
                viewModel.objectWillChange.send()
            }
        }
    }
}

// Preview provider
#Preview {
    MainTabView()
        .environmentObject(PhraseViewModel())
}
