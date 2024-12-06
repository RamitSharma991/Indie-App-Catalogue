//
//  ArticleRowView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//


import SwiftUI

struct ArticleRowView: View {
    let article: Article
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL = article.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "newspaper")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 300, height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text(article.category.rawValue)
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            
            Text(article.title)
                .font(.system(size: settingsManager.fontSize))
                .fontWeight(.bold)
                .lineLimit(2)
            
            if !article.summary.isEmpty {
                Text(article.summary)
                    .font(.system(size: settingsManager.fontSize - 2))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                Text("By \(article.author)")
                    .font(.caption.bold())
                
                Spacer()
                Text(formatDate(article.publishDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
