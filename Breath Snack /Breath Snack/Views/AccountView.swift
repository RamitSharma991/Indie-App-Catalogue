//
//  AccountView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import SwiftUI

struct AccountView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("notifications") private var notificationsEnabled = true
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = components.hour ?? 9
                reminderMinute = components.minute ?? 0
            }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            TextField("Your Name", text: $username)
                                .font(.headline)
                            Text("Breath Snack User")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        DatePicker("Daily Reminder",
                                   selection: reminderTime,
                                   displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                
                Section(header: Text("App Info")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    
                    NavigationLink(destination: HelpView()) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}

// Placeholder views for navigation links
struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy")
            .navigationTitle("Privacy Policy")
    }
}

struct HelpView: View {
    var body: some View {
        Text("Help & Support")
            .navigationTitle("Help & Support")
    }
}
