//
//  BookmarkedArticleDetailView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import SwiftUI
import CoreData

struct BookmarkedArticleDetailView: View {
    let article: BookmarkedArticle
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageURL = article.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title ?? "")
                        .font(.system(size: settingsManager.fontSize + 4))
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(article.author ?? "")
                            .font(.subheadline)
                        Spacer()
                        if let date = article.publishDate {
                            Text(formatDate(date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                    }
                    if let sourceURL = article.sourceURL {
                        Link(destination: sourceURL) {
                            Text("Read original article")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Divider()
                    
                    Text(article.summary ?? "")
                        .font(.system(size: 18))
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                    
                    Text("For more details, kindly check out the original article")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.top, 8)

                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let sourceURL = article.sourceURL {
                ShareSheet(items: [sourceURL])
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
