import SwiftUI

class SessionManager: ObservableObject {
    @Published var sessions: [BreathSession] = []
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "breathingSessions"
    
    init() {
        loadSessions()
    }
    
    func addSession(_ session: BreathSession) {
        sessions.append(session)
        saveSessions()
    }
    
    private func loadSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decodedSessions = try? JSONDecoder().decode([BreathSession].self, from: data) {
            sessions = decodedSessions
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
} 