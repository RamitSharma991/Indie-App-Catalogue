//
//  NewsService.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import Foundation

class NewsService {
    enum NewsError: Error {
        case invalidURL
        case invalidResponse
        case networkError(Error)
        case decodingError(Error)
    }
    
    private let baseURL = "https://hacker-news.firebaseio.com/v0"
    
    func fetchLatestNews() async throws -> [Article] {
        // First fetch top story IDs
        guard let url = URL(string: "\(baseURL)/topstories.json") else {
            throw NewsError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NewsError.invalidResponse
        }
        
        let storyIds = try JSONDecoder().decode([Int].self, from: data)
        
        // Fetch first 20 stories
        let stories = try await withThrowingTaskGroup(of: Article?.self) { group in
            var articles: [Article] = []
            
            // Only fetch first 20 stories to avoid too many requests
            for id in storyIds.prefix(20) {
                group.addTask {
                    try await self.fetchStory(id: id)
                }
            }
            
            for try await story in group {
                if let story = story {
                    articles.append(story)
                }
            }
            
            return articles.sorted { $0.publishDate > $1.publishDate }
        }
        
        return stories
    }
    
    func fetchStory(id: Int) async throws -> Article? {
        guard let url = URL(string: "\(baseURL)/item/\(id).json") else {
            throw NewsError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NewsError.invalidResponse
        }
        
        let item = try JSONDecoder().decode(HNItem.self, from: data)
        
        // Only return items that are stories and not jobs
        guard item.type == "story", item.title != nil else {
            return nil
        }
        
        // Create content from text or title
        let content = stripHTML(item.text ?? "No content available. Kindly check out the original article.")
        
        // Create a summary: either from text (first 200 chars) or from title
        let summary: String
        if let text = item.text {
            let strippedText = stripHTML(text)
            let words = strippedText.split(separator: " ")
            summary = words.prefix(30).joined(separator: " ") + (words.count > 30 ? "..." : "")
        } else {
            summary = item.title ?? ""
        }
        
        // Create a placeholder image URL for tech-related content
        let imageURL = URL(string: "https://picsum.photos/800/400")
//        let imageURL = URL(string: "https://unsplash.com/s/photos/technology")
        
        return Article(
            id: UUID(),
            title: item.title ?? "",
            summary: summary,
            content: content,
            author: item.by ?? "Unknown",
            publishDate: Date(timeIntervalSince1970: TimeInterval(item.time)),
            imageURL: imageURL, // Using placeholder image
            sourceURL: item.url.flatMap { URL(string: $0) },
            category: determineCategory(from: item)
        )
    }
    
    // Helper function to determine category based on title and text
    private func determineCategory(from item: HNItem) -> Article.Category {
        let text = (item.title ?? "").lowercased() + " " + (item.text ?? "").lowercased()
        
        if text.contains("ai") || text.contains("machine learning") || text.contains("neural") {
            return .ai
        } else if text.contains("startup") || text.contains("launch") || text.contains("founder") {
            return .startups
        } else if text.contains("security") || text.contains("hack") || text.contains("vulnerability") {
            return .cybersecurity
        } else if text.contains("game") || text.contains("gaming") || text.contains("playstation") || text.contains("xbox") {
            return .gaming
        } else if text.contains("hardware") || text.contains("device") || text.contains("phone") || text.contains("laptop") {
            return .gadgets
        } else {
            return .software
        }
    }
    
    // Add method to fetch stories by category
    func fetchStoriesByCategory(_ category: Article.Category) async throws -> [Article] {
        // For demo purposes, we'll use different endpoints based on category
        let endpoint: String
        switch category {
        case .software:
            endpoint = "topstories"
        case .startups:
            endpoint = "showstories"
        case .ai:
            endpoint = "beststories"
        default:
            endpoint = "newstories"
        }
        
        guard let url = URL(string: "\(baseURL)/\(endpoint).json") else {
            throw NewsError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NewsError.invalidResponse
        }
        
        let storyIds = try JSONDecoder().decode([Int].self, from: data)
        
        let stories = try await withThrowingTaskGroup(of: Article?.self) { group in
            var articles: [Article] = []
            
            for id in storyIds.prefix(15) {
                group.addTask {
                    try await self.fetchStory(id: id)
                }
            }
            
            for try await story in group {
                if let story = story {
                    articles.append(story)
                }
            }
            
            return articles.sorted { $0.publishDate > $1.publishDate }
        }
        
        return stories
    }
    
    // Inside NewsService class, add this helper function
    private func stripHTML(_ text: String) -> String {
        // Basic HTML stripping
        let stripped = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return stripped
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// HackerNews Item model
struct HNItem: Codable {
    let id: Int
    let type: String?
    let title: String?
    let text: String?
    let url: String?
    let by: String?
    let time: Int
    let kids: [Int]?
    let score: Int?
}
