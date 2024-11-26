//
//  BookmarksView.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var viewModel: PhraseViewModel
    @State private var showingShareSheet = false
    @State private var phraseToShare: Phrase?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.getBookmarkedPhrases().isEmpty {
                    ContentUnavailableView(
                        "No Bookmarks Yet",
                        systemImage: "bookmark.slash",
                        description: Text("Words you bookmark will appear here")
                    )
                } else {
                    List {
                        ForEach(viewModel.getBookmarkedPhrases()) { phrase in
                            BookmarkCard(phrase: phrase) {
                                // Remove bookmark action
                                viewModel.toggleBookmark(for: phrase.id)
                            } shareAction: {
                                phraseToShare = phrase
                                showingShareSheet = true
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Bookmarks")
            .sheet(isPresented: $showingShareSheet) {
                if let phrase = phraseToShare {
                    ShareSheet(activityItems: [viewModel.sharePhrase(phrase)])
                }
            }
        }
    }
}

struct BookmarkCard: View {
    let phrase: Phrase
    let removeAction: () -> Void
    let shareAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(phrase.word)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: shareAction) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: removeAction) {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(.tint)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Text(phrase.phrase)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(phrase.usage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// Helper view for sharing
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
