//
//  PreferencesView.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//
import SwiftUI
import UserNotifications

struct PreferencesView: View {
    @EnvironmentObject var viewModel: PhraseViewModel
    @AppStorage("showUsageExamples") private var showUsageExamples = true
    @AppStorage("showWordOfTheDay") private var showWordOfTheDay = true
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    @AppStorage("reminderTimeSeconds") private var reminderTimeSeconds: Double = 32400 // 9:00 AM in seconds
    @AppStorage("fontSizePreference") private var fontSizePreference = "Normal"
    
    let fontSizeOptions = ["Small", "Normal", "Large"]
    
    // Computed property to convert seconds to Date
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.startOfDay(for: Date()).addingTimeInterval(reminderTimeSeconds)
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderTimeSeconds = Double((components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60)
                if let phrase = viewModel.wordOfTheDay {
                    NotificationManager.shared.scheduleWordOfDayNotification(for: phrase)
                }
            }
        )
    }
    
    var body: some View {
        Form {
            // Display Settings
            Section {
                Toggle("Show Usage Examples", isOn: $showUsageExamples)
                
                Picker("Font Size", selection: $fontSizePreference) {
                    ForEach(fontSizeOptions, id: \.self) { size in
                        Text(size)
                    }
                }
            } header: {
                Text("Display")
            }
            
            // Learning Settings
            Section {
                Toggle("Word Of The Day", isOn: $showWordOfTheDay)
                    .onChange(of: showWordOfTheDay) { newValue, oldValue in
                        // Trigger view model update when preference changes
                        if let phrase = viewModel.wordOfTheDay {
                            NotificationManager.shared.scheduleWordOfDayNotification(for: phrase)
                        }
                    }
            } header: {
                Text("Learning")
            } footer: {
                Text("Show or hide the Word of the Day feature in the Learn tab")
            }
            
            // Notification Settings
            Section {
                Toggle("Daily Reminder", isOn: $dailyReminderEnabled)
                
                if dailyReminderEnabled {
                    DatePicker("Reminder Time",
                              selection: reminderTime,
                              displayedComponents: .hourAndMinute)
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text("Daily reminders help you maintain a consistent learning schedule")
            }
            .onChange(of: dailyReminderEnabled) { newValue, oldValue in
                if newValue {
                    NotificationManager.shared.requestAuthorization()
                }
            }
            
            // Reset Section
            Section {
                Button(role: .destructive, action: resetPreferences) {
                    Label("Reset All Preferences", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("Preferences")
    }
    
    private func resetPreferences() {
        showUsageExamples = true
        dailyReminderEnabled = false
        reminderTimeSeconds = 32400 // Reset to 9:00 AM
        fontSizePreference = "Normal" // Reset font size
    }
}
