//
//  LearnView.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import SwiftUI

struct LearnView: View {
    @EnvironmentObject var viewModel: PhraseViewModel
    @State private var cardOpacity: Double = 1
    @State private var cardOffset: CGFloat = 0
    @State private var showingShareSheet = false
    @State private var gradientColors: [Color] = [.orange, .mint]
    @State private var isWordOfDayExpanded = false
    @AppStorage("lastWordOfDayDate") private var lastWordOfDayDate: Double = 0
    @AppStorage("showWordOfTheDay") private var showWordOfTheDay = true
    
    let possibleColors: [Color] = [.blue, .purple, .pink, .orange, .green, .teal, .indigo, .mint, .red, .cyan, .yellow]
    
    private func randomizeGradient() {
        withAnimation(.easeInOut(duration: 0.5)) {
            gradientColors = [
                possibleColors.randomElement()!,
                possibleColors.randomElement()!
            ]
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.5)
                    } else if viewModel.phrases.isEmpty {
                        ContentUnavailableView(
                            "No Phrases Available",
                            systemImage: "book.closed",
                            description: Text("Unable to load phrases")
                        )
                    } else if let phrase = viewModel.currentPhrase {
                        // Top Bar with Word of Day
                        HStack(alignment: .center) {
                            // Word of the Day Banner
                            if showWordOfTheDay, let wordOfDay = viewModel.wordOfTheDay {
                                WordOfDayBanner(
                                    phrase: wordOfDay,
                                    isExpanded: $isWordOfDayExpanded
                                )
                            }
                        }
                        .padding()
                        
                        // Main Card Container
                        ZStack {
                            WordCard(phrase: phrase)
                                .opacity(cardOpacity)
                                .offset(y: cardOffset)
                        }
                        .frame(height: geometry.size.height * 0.4)
                        
                        // Action Buttons
                        HStack(spacing: 50) {
                            // Existing buttons remain the same
                            ActionButton(
                                action: { viewModel.toggleBookmark(for: phrase.id) },
                                icon: viewModel.bookmarkedPhrases.contains(phrase.id) ? "bookmark.fill" : "bookmark",
                                label: "Bookmark",
                                isActive: viewModel.bookmarkedPhrases.contains(phrase.id)
                            )
                            
                            ActionButton(
                                action: { showingShareSheet = true },
                                icon: "square.and.arrow.up",
                                label: "Share"
                            )
                            
                            ActionButton(
                                action: { randomizeGradient() },
                                icon: "paintpalette",
                                label: "Theme"
                            )

                        }
                        .padding(.vertical)
                        
                        Spacer()
                        
                        // Next Word Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cardOpacity = 0
                                cardOffset = -20
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                viewModel.shuffleToNextPhrase()
                                cardOffset = 20
                                
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    cardOpacity = 1
                                    cardOffset = 0
                                }
                            }
                        }) {
                            Text("Next Word")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.thickMaterial)
                                .foregroundColor(.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 50)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .background(
                LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
                    .opacity(0.3)
                    .ignoresSafeArea()
            )
            .sheet(isPresented: $showingShareSheet) {
                if let phrase = viewModel.currentPhrase {
                    ShareSheet(activityItems: [viewModel.sharePhrase(phrase)])
                }
            }
        }
    }
}

// Action Button Component
struct ActionButton: View {
    let action: (() -> Void)?
    let icon: String
    let label: String
    var isActive: Bool = false
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(isActive ? .pink : .gray)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// Word Card Component
struct WordCard: View {
    let phrase: Phrase
    @AppStorage("showUsageExamples") private var showUsageExamples = true
    @AppStorage("fontSizePreference") private var fontSizePreference = "Normal"
    
    private var wordFontSize: CGFloat {
        switch fontSizePreference {
            case "Small": return 28
            case "Large": return 38
            default: return 32 // Normal
        }
    }
    
    private var contentFontSize: CGFloat {
        switch fontSizePreference {
            case "Small": return 14
            case "Large": return 18
            default: return 16 // Normal
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Word
            HStack {
                Spacer()
                Text(phrase.word)
                    .font(.system(size: wordFontSize, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            // Phrase
            VStack(alignment: .leading, spacing: 8) {
                Text("Phrase:")
                    .font(.system(size: contentFontSize))
                    .foregroundStyle(.secondary)
                Text(phrase.phrase)
                    .font(.system(size: contentFontSize))
            }
            
            // Usage - Only show if enabled
            if showUsageExamples {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Usage:")
                        .font(.system(size: contentFontSize))
                        .foregroundStyle(.secondary)
                    Text(phrase.usage)
                        .font(.system(size: contentFontSize))
                        .italic()
                        .fontWeight(.light)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .accentColor.opacity(0.1), radius: 2, x: 1, y: 4)
        )
        .padding(.horizontal)
    }
}

// Updated Word of Day Banner Component
struct WordOfDayBanner: View {
    let phrase: Phrase
    @Binding var isExpanded: Bool
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack {
            if isExpanded {
                // Expanded Content
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                            rotation += 180
                        }
                    }) {
                        HStack {
                            Label("Word of the Day", systemImage: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(rotation))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text(phrase.word)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.accentColor)
                    
                    Text(phrase.phrase)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(phrase.usage)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                // Collapsed Content
                HStack(spacing: 8) {
                    Label("Word of the Day:", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(phrase.word)
                        .font(.caption.bold())
                        .foregroundColor(.accentColor)
                    
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.caption2)
                        .rotationEffect(.degrees(rotation))

                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                        rotation += 180
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
