//
//  PhraseViewModel.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import SwiftUI
import UserNotifications

// Make sure UserAccount is accessible
class PhraseViewModel: ObservableObject {
    @Published var phrases: [Phrase] = []
    @Published var currentPhrase: Phrase?
    @Published var bookmarkedPhrases: Set<UUID> = []
    @Published var isLoading: Bool = true
    @Published var wordOfTheDay: Phrase?
    @AppStorage("lastWordOfDayDate") private var lastWordOfDayDate: Double = 0
    @AppStorage("wordOfDayId") private var wordOfDayId: String = ""
    
    init() {
        loadPhrases()
        
        // Load bookmarks from user account if signed in
        if UserDefaults.standard.bool(forKey: "isSignedIn"),
           let account = UserAccount.load() {
            bookmarkedPhrases = account.bookmarks
        }
        
        // Check and update word of the day after phrases are loaded
        checkAndUpdateWordOfDay()
    }
    
    private func loadPhrases() {
        isLoading = true
        
        guard let url = Bundle.main.url(forResource: "phrases", withExtension: "json") else {
            print("Error: Could not find phrases.json in bundle")
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            phrases = try JSONDecoder().decode([Phrase].self, from: data)
            print("Successfully loaded \(phrases.count) phrases")
            
            // Load saved bookmarks from UserDefaults
            if let savedBookmarks = UserDefaults.standard.array(forKey: "bookmarkedPhrases") as? [String] {
                bookmarkedPhrases = Set(savedBookmarks.compactMap { UUID(uuidString: $0) })
            }
            
            // Set initial random phrase
            shuffleToNextPhrase()
            
        } catch {
            print("Error loading phrases: \(error)")
        }
        
        isLoading = false
    }
    
    func shuffleToNextPhrase() {
        guard !phrases.isEmpty else { return }
        
        var nextPhrase: Phrase?
        repeat {
            nextPhrase = phrases.randomElement()
        } while nextPhrase?.id == currentPhrase?.id && phrases.count > 1
        
        withAnimation(.easeInOut) {
            currentPhrase = nextPhrase
        }
    }
    
    func toggleBookmark(for phraseId: UUID) {
        if bookmarkedPhrases.contains(phraseId) {
            bookmarkedPhrases.remove(phraseId)
        } else {
            bookmarkedPhrases.insert(phraseId)
        }
        
        // Save bookmarks to UserDefaults and user account if signed in
        let bookmarkStrings = bookmarkedPhrases.map { $0.uuidString }
        UserDefaults.standard.set(bookmarkStrings, forKey: "bookmarkedPhrases")
        
        if UserDefaults.standard.bool(forKey: "isSignedIn"),
           var account = UserAccount.load() {
            account.bookmarks = bookmarkedPhrases
            UserAccount.save(account)
        }
    }
    
    func getBookmarkedPhrases() -> [Phrase] {
        return phrases.filter { bookmarkedPhrases.contains($0.id) }
    }
    
    func sharePhrase(_ phrase: Phrase) -> String {
        return """
        📚 Word: \(phrase.word)
        
        📝 Phrase: \(phrase.phrase)
        
        💡 Usage: \(phrase.usage)
        
        #VocabularyBuilder #Learning
        """
    }
    
    func checkAndUpdateWordOfDay() {
        let calendar = Calendar.current
        let now = Date()
        let lastDate = Date(timeIntervalSince1970: lastWordOfDayDate)
        
        // If we already have a word of the day and it's still the same day, use it
        if !wordOfDayId.isEmpty,
           let existingPhrase = phrases.first(where: { $0.id.uuidString == wordOfDayId }),
           calendar.isDate(lastDate, inSameDayAs: now) {
            wordOfTheDay = existingPhrase
            return
        }
        
        // If it's a new day or we don't have a word yet, select a new one
        updateWordOfDay()
    }
    
    private func updateWordOfDay() {
        guard !phrases.isEmpty else { return }
        
        // Randomly select a new word of the day
        let randomIndex = Int.random(in: 0..<phrases.count)
        wordOfTheDay = phrases[randomIndex]
        
        // Save the word of the day ID and timestamp
        if let phrase = wordOfTheDay {
            wordOfDayId = phrase.id.uuidString
            lastWordOfDayDate = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
            
            // Schedule notification for this word
            NotificationManager.shared.scheduleWordOfDayNotification(for: phrase)
        }
    }
}
