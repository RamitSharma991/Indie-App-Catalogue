//
//  CategoriesViewModel.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//


import Foundation

@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var selectedCategories: Set<Article.Category> = []
    @Published var categoryArticles: [Article.Category: [Article]] = [:]
    @Published var isLoading = false
    
    private let newsService: NewsService
    
    init(newsService: NewsService = NewsService()) {
        self.newsService = newsService
        loadSavedCategories()
        Task {
            await loadSelectedCategories()
        }
    }
    
    func toggleCategory(_ category: Article.Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
            categoryArticles.removeValue(forKey: category)
        } else {
            selectedCategories.insert(category)
            Task {
                await loadArticles(for: category)
            }
        }
    }
    
    private func loadArticles(for category: Article.Category) async {
        isLoading = true
        do {
            let articles = try await newsService.fetchStoriesByCategory(category)
            categoryArticles[category] = articles
        } catch {
            print("Error loading articles for category \(category): \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func loadSelectedCategories() async {
        for category in selectedCategories {
            await loadArticles(for: category)
        }
    }
    
    func applyChanges() {
        saveCategories()
        NotificationCenter.default.post(name: .categoriesUpdated, object: selectedCategories)
    }
    
    private func loadSavedCategories() {
        selectedCategories = Set<Article.Category>()
        
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            if let savedCategories = UserDefaults.standard.stringArray(forKey: "selectedCategories") {
                selectedCategories = Set(savedCategories.compactMap { Article.Category(rawValue: $0) })
            }
        }
    }
    
    private func saveCategories() {
        let categoryStrings = selectedCategories.map { $0.rawValue }
        UserDefaults.standard.set(categoryStrings, forKey: "selectedCategories")
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
    }
}

extension Notification.Name {
    static let categoriesUpdated = Notification.Name("categoriesUpdated")
}
