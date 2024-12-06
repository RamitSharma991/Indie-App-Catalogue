//
//  ArticleDetailView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import SwiftUI
import CoreData

struct ArticleDetailView: View {
    let article: Article
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isBookmarked = false
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                if let imageURL = article.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "newspaper")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("By \(article.author)")
                            .font(.caption.bold())
                        Spacer()
                        Text(formatDate(article.publishDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let sourceURL = article.sourceURL {
                        Link(destination: sourceURL) {
                            Text("Read original article")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Divider()
                    
                    Text(article.summary)
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
                HStack {
                    Button(action: toggleBookmark) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                    
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let sourceURL = article.sourceURL {
                ShareSheet(items: [sourceURL])
            }
        }
        .onAppear {
            checkIfBookmarked()
        }
    }
    
    private func toggleBookmark() {
        if isBookmarked {
            // Remove bookmark
            deleteBookmark()
        } else {
            // Add bookmark
            addBookmark()
        }
        isBookmarked.toggle()
    }
    
    private func addBookmark() {
        let bookmarkedArticle = BookmarkedArticle(context: viewContext)
        bookmarkedArticle.id = article.id
        bookmarkedArticle.title = article.title
        bookmarkedArticle.summary = article.summary
        bookmarkedArticle.content = article.content
        bookmarkedArticle.author = article.author
        bookmarkedArticle.publishDate = article.publishDate
        bookmarkedArticle.imageURL = article.imageURL
        bookmarkedArticle.sourceURL = article.sourceURL
        
        try? viewContext.save()
        
        // Send notification when bookmark is added
        NotificationManager.sendBookmarkNotification(for: article)
    }
    
    private func deleteBookmark() {
        let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", article.id as CVarArg)
        
        if let bookmarkedArticles = try? viewContext.fetch(fetchRequest) {
            for bookmarkedArticle in bookmarkedArticles {
                viewContext.delete(bookmarkedArticle)
            }
            try? viewContext.save()
        }
    }
    
    private func checkIfBookmarked() {
        let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", article.id as CVarArg)
        
        if let count = try? viewContext.count(for: fetchRequest) {
            isBookmarked = count > 0
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
