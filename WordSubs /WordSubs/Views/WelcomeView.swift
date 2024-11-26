//
//  WelcomeView.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showMainView = false
    @State private var opacity = 1.0
    @State private var gradientColors: [Color] = [.mint.opacity(0.6), .orange.opacity(0.4)]
    
    var body: some View {
        ZStack {
            if !showMainView {
                // Welcome content
                LinearGradient(
                    colors: gradientColors,
                    startPoint: UnitPoint(x: -0.5, y: -0.5),
                    endPoint: UnitPoint(x: 1.5, y: 1.5)
                )
                .ignoresSafeArea()
                
                VStack(spacing: 1) {
                    Spacer()
                    // App Icon and Title
                    VStack(spacing: 5) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.tint)
                            .padding(30)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        
                        Text("Word")
                            .font(.system(.largeTitle, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("Subs")
                            .font(.system(.largeTitle, weight: .light))
                            .foregroundStyle(.secondary)
                        
                        //Subheadline
                        Text("Learn one-word substitutes for common phrases")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 50)
                            .padding(.vertical)
                    }
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            opacity = 0
                            showMainView = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(.ultraThinMaterial)
                            .foregroundColor(.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 100)
                }
            }
            
            if showMainView {
                MainTabView()
                    .opacity(1 - opacity)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showMainView)
    }
}
