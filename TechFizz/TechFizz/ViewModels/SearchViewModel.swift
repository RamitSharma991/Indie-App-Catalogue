//
//  SearchViewModel.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//


import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [Article] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let newsService: NewsService
    
    init(newsService: NewsService = NewsService()) {
        self.newsService = newsService
        
        // Debounce search queries to avoid too many API calls
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    Task {
                        await self?.performSearch(query: query)
                    }
                } else {
                    self?.searchResults = []
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // In a real app, you would call a search endpoint
            // For now, we'll filter the latest news
            let articles = try await newsService.fetchLatestNews()
            searchResults = articles.filter { article in
                article.title.localizedCaseInsensitiveContains(query) ||
                article.summary.localizedCaseInsensitiveContains(query)
            }
        } catch {
            searchResults = []
            print("Search error: \(error.localizedDescription)")
        }
    }
}
