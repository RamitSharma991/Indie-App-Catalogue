//
//  NotificationManager.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    func scheduleWordOfDayNotification(for phrase: Phrase?) {
        guard let phrase = phrase else { return }
        
        // Remove any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Get user's preferred time from AppStorage
        let reminderTimeSeconds = UserDefaults.standard.double(forKey: "reminderTimeSeconds")
        let dailyReminderEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")
        
        guard dailyReminderEnabled else { return }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Word of the Day: \(phrase.word)"
        content.body = phrase.phrase
        content.sound = .default
        
        // Create calendar components for the notification time
        var components = DateComponents()
        components.hour = Int(reminderTimeSeconds) / 3600
        components.minute = (Int(reminderTimeSeconds) % 3600) / 60
        
        // Create trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "wordOfDay",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
