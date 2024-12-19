//
//  WelcomeView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @State private var isWelcomeComplete = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground) // Using system background color instead
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "wind")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Breath Snack")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Take a moment to breathe")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    withAnimation {
                        isWelcomeComplete = true
                    }
                }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                }
            }
        }
        .fullScreenCover(isPresented: $isWelcomeComplete) {
            MainTabView()
        }
    }
} 
