//
//  NotificationSettingsView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//


import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @AppStorage("notifyBreakingNews") private var notifyBreakingNews = false
    @AppStorage("notifyBookmarks") private var notifyBookmarks = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Breaking News", isOn: $notifyBreakingNews)
                    .onChange(of: notifyBreakingNews) { newValue in
                        if newValue {
                            requestNotificationPermission()
                        }
                    }
                
                Toggle("Bookmarks Added", isOn: $notifyBookmarks)
                    .onChange(of: notifyBookmarks) { newValue in
                        if newValue {
                            requestNotificationPermission()
                        }
                    }
            } footer: {
                Text("Get instant notifications for breaking news and when articles are bookmarked")
            }
            
            Section {
                Button("Test Notification") {
                    sendTestNotification()
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Notifications")
        .alert("Notification Permission Required", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable notifications in Settings to receive updates about breaking news and bookmarks.")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if !granted {
                DispatchQueue.main.async {
                    showPermissionAlert = true
                }
            }
        }
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Breaking News!"
        content.body = "New article: 'AI Breakthrough: ChatGPT Achieves Human-Level Understanding'\nTap to read more."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

// Notification Manager class
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
    }
    
    func setup() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    static func sendBreakingNewsNotification(for article: Article) {
        guard UserDefaults.standard.bool(forKey: "notifyBreakingNews") else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Breaking News!"
        content.body = "\(article.title)\n\(article.summary)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func sendBookmarkNotification(for article: Article) {
        guard UserDefaults.standard.bool(forKey: "notifyBookmarks") else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Article Bookmarked"
        content.body = "You've bookmarked: \(article.title)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
