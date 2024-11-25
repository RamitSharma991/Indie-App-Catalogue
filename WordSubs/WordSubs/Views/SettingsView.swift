//
//  SettingsView.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        AccountView()
                    } label: {
                        Label("Account", systemImage: "person.circle")
                    }
                    
                    NavigationLink {
                        PreferencesView()
                    } label: {
                        Label("Preferences", systemImage: "slider.horizontal.2.square")
                    }
                }
                
                Section {
                    ShareLink(
                        item: URL(string: "https://apps.apple.com/app/id123456789")!,
                        preview: SharePreview(
                            "Check out this app!",
                            image: Image(systemName: "square.and.arrow.up")
                        )
                    ) {
                        Label("Share App", systemImage: "square.and.arrow.up")
                    }
                    
                    Link(destination: URL(string: "https://apps.apple.com/app/id123456789")!) {
                        Label("Rate on App Store", systemImage: "star")
                    }
                    
                    NavigationLink {
                        Text("Privacy Policy")
                    } label: {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
