//
//  CategoriesView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @EnvironmentObject var settingsManager: SettingsManager
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Article.Category.allCases, id: \.self) { category in
                        CategoryCardView(
                            category: category,
                            isSelected: viewModel.selectedCategories.contains(category),
                            onTap: { viewModel.toggleCategory(category) }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.applyChanges()
                    }
                    .disabled(viewModel.selectedCategories.isEmpty)
                }
            }
        }
    }
}

struct CategoryCardView: View {
    let category: Article.Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: iconName(for: category))
                    .font(.system(size: 30))
                Text(category.rawValue)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private func iconName(for category: Article.Category) -> String {
        switch category {
        case .ai: return "cpu"
        case .gadgets: return "laptopcomputer"
        case .startups: return "lightbulb.max"
        case .cybersecurity: return "lock.shield"
        case .gaming: return "gamecontroller"
        case .software: return "chevron.left.forwardslash.chevron.right"
        }
    }
}
