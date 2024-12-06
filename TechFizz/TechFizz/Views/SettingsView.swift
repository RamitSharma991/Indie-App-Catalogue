//
//  SettingsView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showResetAlert = false
    
    let regions = ["US", "UK", "EU", "AS", "Global"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $settingsManager.isDarkMode)
                }
                
                Section("Region") {
                    Picker("News Region", selection: $settingsManager.selectedRegion) {
                        ForEach(regions, id: \.self) { region in
                            Text(region).tag(region)
                        }
                    }
                }
                
                Section("Notifications") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Text("Notification Preferences")
                    }
                }
                
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://yourapp.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://yourapp.com/terms")!)
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Reset All Settings") {
                        showResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Settings", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetSettings()
                }
            } message: {
                Text("Are you sure you want to reset all settings to default?")
            }
        }
    }
    
    private func resetSettings() {
        settingsManager.isDarkMode = false
        settingsManager.selectedRegion = "US"
    }
}
