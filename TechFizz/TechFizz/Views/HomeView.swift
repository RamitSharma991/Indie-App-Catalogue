//
//  HomeView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    ForEach(viewModel.articles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            VStack(alignment: .center, spacing: 0) {
                                if let imageURL = article.imageURL {
                                    AsyncImage(url: imageURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .foregroundColor(.gray.opacity(0.2))
                                    }
                                    .frame(height: 200)
                                    .clipped()
                                    
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(article.category.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(article.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)

                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                            }
                            .frame(maxWidth: 360)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical)

            }
            .scrollIndicators(.hidden)
            .refreshable {
                await viewModel.refreshContent()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refreshContent()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showSearch.toggle() }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSearch) {
                SearchView()
            }
            .navigationTitle("Discover")
        }
    }
}
