//
//  AccountView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//
//

import SwiftUI
import UserNotifications

struct AccountView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("notifications") private var notificationsEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    
    @Environment(\.scenePhase) private var scenePhase
    
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = components.hour ?? 9
                reminderMinute = components.minute ?? 0
                if notificationsEnabled {
                    scheduleNotification()
                }
            }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .accessibilityLabel("Profile Picture")
                        
                        VStack(alignment: .leading) {
                            TextField("Your Name", text: $username)
                                .textContentType(.name)
                                .font(.headline)
                            Text("Breath Snack User")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Profile")
                } footer: {
                    Text("Your profile information is stored locally on your device")
                }
                
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            Task {
                                if newValue {
                                    await requestNotificationPermission()
                                } else {
                                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                }
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Daily Reminder",
                                 selection: reminderTime,
                                 displayedComponents: .hourAndMinute)
                    }
                    
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("Daily reminders help you maintain a consistent breathing practice")
                }
                
                Section {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    
                    NavigationLink {
                        HelpView()
                    } label: {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("App Info")
                }
            }
            .navigationTitle("Account")
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    Task {
                        await checkNotificationStatus()
                    }
                }
            }
        }
    }
    
    private func requestNotificationPermission() async {
        do {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            }
            
            if settings.authorizationStatus == .authorized {
                scheduleNotification()
            } else {
                notificationsEnabled = false
            }
        } catch {
            notificationsEnabled = false
        }
    }
    
    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus != .authorized {
            notificationsEnabled = false
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for a Breathing Break"
        content.body = "Take a moment to refresh your mind and body with a breathing exercise."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyBreathingReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request)
    }
}

// Placeholder views with basic structure
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy")
                .font(.title)
                .padding(.top)
            // Add your privacy policy content here
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpView: View {
    var body: some View {
        List {
            Section(header: Text("Frequently Asked Questions")) {
                // Add your FAQ items here
            }
            
            Section(header: Text("Contact Support")) {
                // Add your support contact information here
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}
