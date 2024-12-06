//
//  BookmarksView.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import SwiftUI
import CoreData

struct BookmarksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookmarkedArticle.publishDate, ascending: false)],
        animation: .default)
    private var bookmarkedArticles: FetchedResults<BookmarkedArticle>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarkedArticles) { article in
                    NavigationLink {
                        BookmarkedArticleDetailView(article: article)
                    } label: {
                        BookmarkedArticleRowView(article: article)
                    }
                }
                .onDelete(perform: deleteBookmarks)
            }
            .navigationTitle("Bookmarks")
            .overlay {
                if bookmarkedArticles.isEmpty {
                    ContentUnavailableView(
                        "No Bookmarks",
                        systemImage: "bookmark.slash",
                        description: Text("Articles you bookmark will appear here")
                    )
                }
            }
        }
    }
    
    private func deleteBookmarks(offsets: IndexSet) {
        withAnimation {
            offsets.map { bookmarkedArticles[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}
