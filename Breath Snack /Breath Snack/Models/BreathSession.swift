//
//  BreathSession.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import SwiftUI

struct BreathSession: Identifiable, Codable {
    let id: UUID
    let routineTitle: String
    let date: Date
    let duration: Int
    let routineColor: String
    let breathPattern: BreathPattern
    
    init(routineTitle: String, duration: Int, color: Color, pattern: BreathPattern) {
        self.id = UUID()
        self.routineTitle = routineTitle
        self.date = Date()
        self.duration = duration
        self.routineColor = color.description
        self.breathPattern = pattern
    }
}
