//
//  WelcomeView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isWelcomeComplete = false
    @State private var appearAnimation = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App icon and title group
                VStack(spacing: 25) {
                    Image(systemName: "wind")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundStyle(.accent)
                        .symbolEffect(.bounce, value: isAnimating)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                                isAnimating.toggle()
                            }
                        }
                    
                    VStack(spacing: 12) {
                        Text("Breath Snack")
                            .font(.system(size: 40, weight: .thin, design: .rounded))
                        
                        Text("Take a moment to breathe")
                            .font(.system(size: 20, weight: .thin))
                            .foregroundStyle(.secondary)
                    }
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 20)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring) {
                            isWelcomeComplete = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.white)
                            .frame(width: 220, height: 54)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 27))
                            .shadow(color: .accent.opacity(0.3), radius: 10, y: 5)
                    }
                    
                    Button(action: {
                        // Handle sign in action
                    }) {
                        Text("Already have an account? Sign in")
                            .font(.system(size: 16, weight: .thin))
                            .foregroundStyle(.secondary)
                    }
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 20)
                
                Spacer()
                    .frame(height: 50)
            }
            .padding(.horizontal, 30)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                appearAnimation = true
            }
        }
        .preferredColorScheme(.light) // Force light mode for welcome screen only
        .fullScreenCover(isPresented: $isWelcomeComplete) {
            MainTabViewContainer() // Wrap MainTabView in a container that doesn't force any color scheme
        }
    }
}

// Container for MainTabView that respects system theme
struct MainTabViewContainer: View {
    var body: some View {
        MainTabView()
            .preferredColorScheme(.dark) // Explicitly set to dark theme
    }
}

struct AnimatedGradientBackground: View {
    @State private var start = UnitPoint(x: 0, y: 0)
    @State private var end = UnitPoint(x: 1, y: 1)
    
    let colors: [Color] = [
        Color.white,
        Color(red: 0.8, green: 0.7, blue: 1.0),  // Light purple
        Color(red: 1.0, green: 0.8, blue: 0.9)  // Light pink
    ]
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        LinearGradient(colors: colors, startPoint: start, endPoint: end)
            .ignoresSafeArea()
            .blur(radius: 50)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 3)) {
                    start = randomPoint()
                    end = randomPoint()
                }
            }
    }
    
    private func randomPoint() -> UnitPoint {
        UnitPoint(x: Double.random(in: 0...1),
                 y: Double.random(in: 0...1))
    }
}
