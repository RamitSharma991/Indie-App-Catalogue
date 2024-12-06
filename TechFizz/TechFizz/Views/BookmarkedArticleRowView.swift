//
//  BookmarkedArticleRowView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import SwiftUI
import CoreData

struct BookmarkedArticleRowView: View {
    let article: BookmarkedArticle
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(article.title ?? "")
                .font(.system(size: settingsManager.fontSize))
                .fontWeight(.semibold)
                .lineLimit(2)
            
            HStack {
                Text(article.author ?? "")
                    .font(.caption)
                Spacer()
                if let date = article.publishDate {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
