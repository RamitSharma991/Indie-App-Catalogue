//
//  HomeViewModel.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var showSearch = false
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private let newsService: NewsService
    private var selectedCategories: Set<Article.Category> = []
    
    init(newsService: NewsService = NewsService()) {
        self.newsService = newsService
        
        // Start with no categories selected
        selectedCategories = Set<Article.Category>()
        
        // Only load saved categories if this is not the first launch
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            if let savedCategories = UserDefaults.standard.stringArray(forKey: "selectedCategories") {
                selectedCategories = Set(savedCategories.compactMap { Article.Category(rawValue: $0) })
            }
        }
        
        Task {
            await loadInitialContent()
        }
        
        // Listen for category updates
        NotificationCenter.default.publisher(for: .categoriesUpdated)
            .sink { [weak self] notification in
                if let categories = notification.object as? Set<Article.Category> {
                    self?.selectedCategories = categories
                    Task {
                        await self?.loadInitialContent()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func loadInitialContent() async {
        isLoading = true
        do {
            let allArticles = try await newsService.fetchLatestNews()
            
            // Filter articles based on selected categories
            if selectedCategories.isEmpty {
                articles = allArticles
            } else {
                articles = allArticles.filter { selectedCategories.contains($0.category) }
            }
            
            // Send notification for the latest article
            if let latestArticle = articles.first {
                NotificationManager.sendBreakingNewsNotification(for: latestArticle)
            }
        } catch {
            self.error = error
            print("Error loading news: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func refreshContent() async {
        await loadInitialContent()
    }
}
