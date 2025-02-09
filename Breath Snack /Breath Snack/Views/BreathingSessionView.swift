//
//  BreathingSessionView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import SwiftUI

struct BreathingSessionView: View {
    let routine: BreathRoutine
    @State private var timeRemaining: Int
    @State private var breathPhase = "Inhale"
    @State private var scale: CGFloat = 1.0
    @State private var innerScale: CGFloat = 1.0
    @State private var middleScale: CGFloat = 1.0
    @State private var holdTime: Int = 0
    @State private var isSessionActive = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    
    init(routine: BreathRoutine) {
        self.routine = routine
        _timeRemaining = State(initialValue: routine.duration)
    }
    private var gradientColors: [Color] {
        switch routine.breathPattern {
        case .diaphragmatic:
            return [Color(hex: "A5CAD2"), Color(hex: "FF7B89"), Color(hex:"A5CAD2"), Color(hex:"8A5082")]
        case .fourSevenEight:
            return [Color(hex: "8A5082"), Color(hex: "A5CAD2"), Color(hex: "A5CAD2"), Color(hex: "FF7B89")]
        case .bellowsBreath:
            return [Color(hex: "438BD3"), Color(hex: "FF9DDA"), Color(hex: "EE4392"), Color(hex: "004E99")]
        case .breathOfFire:
            return [Color(hex: "EE4392"), Color(hex: "004E99"), Color(hex: "438BD3"), Color(hex: "FF9DDA")]
        case .boxBreathing:
            return [Color(hex: "004E99"), Color(hex: "BCE6FF"), Color(hex: "9FA5D5"), Color(hex: "E0F8F7")]
        case .alternateNostril:
            return [Color(hex: "9FA5D5"), Color(hex: "E0F8F7"), Color(hex: "004E99"), Color(hex: "BCE6FF")]
        case .fiveFiveFive:
            return [Color(hex: "D9AAC7"), Color(hex: "3127A8"), Color(hex: "451E61"), Color(hex: "FB8E6A")]
        case .lengthenedExhale:
            return [Color(hex: "451E61"), Color(hex: "FB8E6A"), Color(hex: "D9AAC7"), Color(hex: "3127A8")]
        case .deepVisualization:
            return [Color(hex: "F9E866"), Color(hex: "447A7A"), Color(hex: "F1EAB9"), Color(hex: "FF8C8C")]
        case .coherentBreathing:
            return [Color(hex: "F1EAB9"), Color(hex: "FF8C8C"), Color(hex: "447A7A"), Color(hex: "F9E866")]
        case .rhythmicRunning:
            return [Color(hex: "D8B5FF"), Color(hex: "1EAE98"), Color(hex: "2B4C59"), Color(hex: "4F3466")]
        case .pursedLip:
            return [Color(hex: "2B4C59"), Color(hex: "988080"), Color(hex: "D8B5FF"), Color(hex: "1EAE98")]
        case .slowBodyScan:
            return [Color(hex: "FFA166"), Color(hex: "5048FF"), Color(hex: "A2C374"), Color(hex: "F36A8F")]
        case .mindfulCounting:
            return [Color(hex: "A2C374"), Color(hex: "F36A8F"), Color(hex: "FFA166"), Color(hex: "5048FF")]
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .overlay(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Section: Info Card + Breath Text
                VStack(spacing: 16) {
                    // Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(routine.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(routine.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                        
                        Text(timeString(from: timeRemaining))
                            .font(.headline)
                            .foregroundColor(gradientColors[1])
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Combined Breathing Animation Section
                    if isSessionActive {
                        ZStack(alignment: .center) {
                            VStack(spacing: 16) {
                                // Circles in background with hold time
                                ZStack {
                            AnimatedCircles(
                                scale: scale,
                                middleScale: middleScale,
                                innerScale: innerScale,
                                gradientColors: gradientColors
                            )
                            .animation(.easeInOut(duration: getAnimationDuration()), value: scale)
                            .animation(.easeInOut(duration: getAnimationDuration()).delay(0.1), value: middleScale)
                            .animation(.easeInOut(duration: getAnimationDuration()).delay(0.2), value: innerScale)
                            
                                    // Only the hold time number
                                    if holdTime > 0 {
                                        Text("\(holdTime)")
                                            .font(.system(size: 60, weight: .bold))
                                            .foregroundColor(gradientColors[1])
                                            .frame(height: 80)
                                            .transition(.opacity.combined(with: .scale))
                                            .contentTransition(.numericText())
                                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: holdTime)
                                    }
                                }
                                
                                // Breath phase text in separate rectangle
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 50)
                                    .overlay(
                                        Text(breathPhase)
                                            .font(.system(size: 24, design: .rounded))
                                            .foregroundColor(gradientColors[1])
                                            .opacity(holdTime > 0 ? 0.6 : 1.0)
                                            .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                                            .contentTransition(.identity)
                                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: breathPhase)
                                    )
                                    .frame(maxWidth: 300)
                                    .transition(AnyTransition.opacity.combined(with: .scale))
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: breathPhase)
                        }
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 0.5)
                        }
                    }
                    
                    Spacer()
                    
                    // End Session Button
                    Button(action: endSession) {
                        Text("End Session")
                            .font(.headline)
                            .foregroundColor(gradientColors[1])
                            .frame(width: 200, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(gradientColors[0])
                                    .opacity(0.9)
                            )
                    }
                    .padding(.bottom)
                }
                .padding(.top)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSessionActive = true
                startBreathingSession()
            }
        }
    }
    
    private func getAnimationDuration() -> Double {
        switch routine.breathPattern {
        case .diaphragmatic: return 4
        case .fourSevenEight: return 4
        case .bellowsBreath: return 1
        case .breathOfFire: return 1
        case .boxBreathing: return 4
        case .alternateNostril: return 5
        case .fiveFiveFive: return 5
        case .lengthenedExhale: return 6
        case .deepVisualization: return 5
        case .coherentBreathing: return 5
        case .rhythmicRunning: return 3
        case .pursedLip: return 4
        case .slowBodyScan: return 6
        case .mindfulCounting: return 4
        }
    }
    
    private func startBreathingSession() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                updateBreathPhase()
            } else {
                timer.invalidate()
                endSession()
            }
        }
    }
    
    private func updateBreathPhase() {
        switch routine.breathPattern {
        case .diaphragmatic:
            updateDiaphragmaticBreathing()
        case .fourSevenEight:
            updateFourSevenEightBreathing()
        case .bellowsBreath:
            updateBellowsBreath()
        case .breathOfFire:
            updateBreathOfFire()
        case .boxBreathing:
            updateBoxBreathing()
        case .alternateNostril:
            updateAlternateNostrilBreathing()
        case .fiveFiveFive:
            updateFiveFiveFiveBreathing()
        case .lengthenedExhale:
            updateLengthenedExhaleBreathing()
        case .deepVisualization:
            updateDeepVisualizationBreathing()
        case .coherentBreathing:
            updateCoherentBreathing()
        case .rhythmicRunning:
            updateRhythmicRunningBreath()
        case .pursedLip:
            updatePursedLipBreathing()
        case .slowBodyScan:
            updateSlowBodyScanBreathing()
        case .mindfulCounting:
            updateMindfulCountingBreathing()
        }
    }
    
    private func animateBreathing(expand: Bool) {
        withAnimation {
            scale = expand ? 1.3 : 1.0
            middleScale = expand ? 1.4 : 1.0
            innerScale = expand ? 1.5 : 1.0
        }
    }
    
    private func updateDiaphragmaticBreathing() {
        let cycle = timeRemaining % 8
        if cycle >= 4 {
            breathPhase = "Inhale"
            animateBreathing(expand: true)
        } else {
            breathPhase = "Exhale"
            animateBreathing(expand: false)
        }
    }
    
    private func updateFourSevenEightBreathing() {
        let cycle = timeRemaining % 19 // 4 + 7 + 8
        if cycle >= 15 {
            breathPhase = "Inhale (4)"
            holdTime = cycle - 15
            animateBreathing(expand: true)
        } else if cycle >= 8 {
            breathPhase = "Hold (7)"
            holdTime = cycle - 8
            animateBreathing(expand: true)
        } else {
            breathPhase = "Exhale (8)"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateBoxBreathing() {
        let cycle = timeRemaining % 16 // 4 + 4 + 4 + 4
        if cycle >= 12 {
            breathPhase = "Inhale"
            holdTime = cycle - 12
            animateBreathing(expand: true)
        } else if cycle >= 8 {
            breathPhase = "Hold"
            holdTime = cycle - 8
            animateBreathing(expand: true)
        } else if cycle >= 4 {
            breathPhase = "Exhale"
            holdTime = cycle - 4
            animateBreathing(expand: false)
        } else {
            breathPhase = "Hold"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateBreathOfFire() {
        let cycle = timeRemaining % 2
        if cycle >= 1 {
            breathPhase = "Passive In"
            animateBreathing(expand: true)
        } else {
            breathPhase = "Force Out"
            animateBreathing(expand: false)
        }
        holdTime = 0
    }
    
    private func updateFiveFiveFiveBreathing() {
        let cycle = timeRemaining % 15 // 5 + 5 + 5
        if cycle >= 10 {
            breathPhase = "Inhale (5)"
            holdTime = cycle - 10
            animateBreathing(expand: true)
        } else if cycle >= 5 {
            breathPhase = "Hold (5)"
            holdTime = cycle - 5
            animateBreathing(expand: true)
        } else {
            breathPhase = "Exhale (5)"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateCoherentBreathing() {
        let cycle = timeRemaining % 10 // 5 + 5
        if cycle >= 5 {
            breathPhase = "Inhale (5)"
            holdTime = cycle - 5
            animateBreathing(expand: true)
        } else {
            breathPhase = "Exhale (5)"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateBellowsBreath() {
        let roundDuration = 30 // 30 seconds per round
        let restDuration = 15 // 15 seconds rest between rounds
        let totalRoundTime = roundDuration + restDuration
        let currentRound = (timeRemaining / totalRoundTime) + 1
        
        if currentRound <= 3 { // Only do 3 rounds
            let timeInCurrentRound = timeRemaining % totalRoundTime
            
            if timeInCurrentRound > restDuration {
                // Active breathing phase
                let breathCycle = timeInCurrentRound % 2
                if breathCycle >= 1 {
                    breathPhase = "Quick Inhale"
                    animateBreathing(expand: true)
                } else {
                    breathPhase = "Quick Exhale"
                    animateBreathing(expand: false)
                }
                holdTime = 0
            } else {
                // Rest phase
                breathPhase = "Rest"
                holdTime = timeInCurrentRound
                animateBreathing(expand: false)
            }
            
            // Add round indicator to the breath phase
            if timeInCurrentRound > restDuration {
                breathPhase += " (Round \(currentRound)/3)"
            } else {
                breathPhase = "Rest (\(timeInCurrentRound)s)"
            }
        } else {
            // Session complete
            breathPhase = "Complete"
            holdTime = 0
        }
    }
    
    private func updateAlternateNostrilBreathing() {
        let cycle = timeRemaining % 20 // 5 + 5 + 5 + 5
        if cycle >= 15 {
            breathPhase = "Right Nostril In"
            holdTime = cycle - 15
            animateBreathing(expand: true)
        } else if cycle >= 10 {
            breathPhase = "Left Nostril Out"
            holdTime = cycle - 10
            animateBreathing(expand: false)
        } else if cycle >= 5 {
            breathPhase = "Left Nostril In"
            holdTime = cycle - 5
            animateBreathing(expand: true)
        } else {
            breathPhase = "Right Nostril Out"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateLengthenedExhaleBreathing() {
        let cycle = timeRemaining % 12 // 4 + 8
        if cycle >= 8 {
            breathPhase = "Inhale (4)"
            holdTime = cycle - 8
            animateBreathing(expand: true)
        } else {
            breathPhase = "Long Exhale (8)"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateDeepVisualizationBreathing() {
        let cycle = timeRemaining % 10
        if cycle >= 5 {
            breathPhase = "Inhale & Visualize Peace"
            holdTime = cycle - 5
            animateBreathing(expand: true)
        } else {
            breathPhase = "Release Tension"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateRhythmicRunningBreath() {
        let cycle = timeRemaining % 5 // 3 + 2
        if cycle >= 2 {
            breathPhase = "Inhale (3 Steps)"
            holdTime = cycle - 2
            animateBreathing(expand: true)
        } else {
            breathPhase = "Exhale (2 Steps)"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updatePursedLipBreathing() {
        let cycle = timeRemaining % 8 // 3 + 5
        if cycle >= 5 {
            breathPhase = "Nose Inhale (3)"
            holdTime = cycle - 5
            animateBreathing(expand: true)
        } else {
            breathPhase = "Pursed Exhale (5)"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateSlowBodyScanBreathing() {
        let cycle = timeRemaining % 12 // 6 + 6
        if cycle >= 6 {
            breathPhase = "Inhale & Scan Up"
            holdTime = cycle - 6
            animateBreathing(expand: true)
        } else {
            breathPhase = "Exhale & Relax"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func updateMindfulCountingBreathing() {
        let cycle = timeRemaining % 8 // 4 + 4
        if cycle >= 4 {
            breathPhase = "In & Count Up"
            holdTime = cycle - 4
            animateBreathing(expand: true)
        } else {
            breathPhase = "Out & Count Down"
            holdTime = cycle
            animateBreathing(expand: false)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func endSession() {
        let session = BreathSession(
            routineTitle: routine.title,
            duration: routine.duration - timeRemaining, // Only count completed time
            color: gradientColors[0], // Use first gradient color instead
            pattern: routine.breathPattern
        )
        sessionManager.addSession(session)
        dismiss()
    }
}

struct BreathText: View {
    let breathPhase: String
    let holdTime: Int
    let gradientColors: [Color]
    
    var body: some View {
        VStack(spacing: 16) {
            // Hold time number (stays inside AnimatedCircles)
            Group {
                if holdTime > 0 {
                    Text("\(holdTime)")
                        .font(.system(size: 60, weight: .heavy))
                        .foregroundColor(gradientColors[1])
                        .frame(height: 80)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: holdTime)
                }
            }
            
            // Breath phase text (in separate rounded rectangle)
            Group {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .frame(height: 50)
                    .overlay(
                        Text(breathPhase)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(gradientColors[1])
                            .opacity(holdTime > 0 ? 0.6 : 1.0)
                    )
                    .frame(maxWidth: 280)
            }
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: breathPhase)
        }
    }
}

struct AnimatedCircles: View {
    let scale: CGFloat
    let middleScale: CGFloat
    let innerScale: CGFloat
    let gradientColors: [Color]
    @State private var animate = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .frame(width: 280, height: 280)
            .overlay(
                ZStack {
                    // Outer circle (larger, no stroke)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors + gradientColors,
                                startPoint: animate ? .topTrailing : .topLeading,
                                endPoint: animate ? .bottomLeading : .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: gradientColors,
                                        center: .center,
                                        startRadius: animate ? 10 : 40,
                                        endRadius: animate ? 50 : 200
                                    )
                                )
                                .blendMode(.colorBurn)
                                .opacity(0.5)
                        )
                        .opacity(0.15)
                        .frame(width: 200, height: 200)
                        .scaleEffect(scale)
                    
                    // Middle circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors + gradientColors,
                                startPoint: animate ? .topLeading : .bottomTrailing,
                                endPoint: animate ? .bottomTrailing : .topLeading
                            )
                        )
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: gradientColors,
                                        center: .center,
                                        startRadius: animate ? 40 : 10,
                                        endRadius: animate ? 200 : 50
                                    )
                                )
                                .blendMode(.colorBurn)
                                .opacity(0.5)
                        )
                        .opacity(0.2)
                        .frame(width: 160, height: 160)
                        .scaleEffect(middleScale)
                    
                    // Inner circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors + gradientColors,
                                startPoint: animate ? .bottomLeading : .topTrailing,
                                endPoint: animate ? .topTrailing : .bottomLeading
                            )
                        )
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: gradientColors,
                                        center: .center,
                                        startRadius: animate ? 20 : 80,
                                        endRadius: animate ? 100 : 20
                                    )
                                )
                                .blendMode(.colorBurn)
                                .opacity(0.5)
                        )
                        .opacity(0.45)
                        .frame(width: 120, height: 120)
                        .scaleEffect(innerScale)
                }
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            .onAppear {
                withAnimation(
                    Animation
                        .linear(duration: 8)
                        .repeatForever(autoreverses: true)
                ) {
                    animate.toggle()
                }
            }
    }
}
