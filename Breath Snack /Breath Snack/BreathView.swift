//
//  BreathView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import SwiftUI

struct BreathView: View {
    @State private var selectedRoutine: BreathRoutine?
    @State private var showingRoutine = false
    @AppStorage("quickAccessRoutines") private var quickAccessData: Data = Data()
    @State private var quickAccessRoutines: [BreathRoutine] = []
    @State private var showingRoutinePicker = false
    
    let categories = [
        BreathCategory(
            title: "Relaxation & Stress Relief",
            routines: [
                BreathRoutine(
                    title: "Diaphragmatic (Abdominal) Breathing",
                    description: "Sit or lie down comfortably, placing one hand on your chest and the other on your belly. Breathe in deeply through your nose, allowing your diaphragm to expand.",
                    duration: 600, // 10 minutes
                    breathPattern: .diaphragmatic
                ),
                BreathRoutine(
                    title: "4-7-8 Breathing (Relaxing Breath)",
                    description: "Inhale through your nose for a count of 4, hold your breath for a count of 7, and exhale completely through your mouth for a count of 8.",
                    duration: 300, // 5 minutes
                    breathPattern: .fourSevenEight
                )
            ]
        ),
        BreathCategory(
            title: "Physical Performance",
            routines: [
                BreathRoutine(
                    title: "Rhythmic Running Breath",
                    description: "Inhale for 3 steps and exhale for 2 steps while running. Adjust according to your pace and comfort level.",
                    duration: 300, // 5 minutes
                    breathPattern: .rhythmicRunning
                ),
                BreathRoutine(
                    title: "Pursed-Lip Breathing",
                    description: "Inhale through your nose and exhale through pursed lips, controlling the exhale to make it longer.",
                    duration: 300, // 5 minutes
                    breathPattern: .pursedLip
                )
            ]
        ),
        BreathCategory(
            title: "Energy & Focus",
            routines: [
                BreathRoutine(
                    title: "Bellows Breath (Bhastrika)",
                    description: "Sit comfortably, inhale and exhale forcefully through the nose, keeping the mouth closed. Engage your diaphragm to create a quick, rhythmic breath.",
                    duration: 90, // 30 seconds x 3 rounds
                    breathPattern: .bellowsBreath
                ),
                BreathRoutine(
                    title: "Breath of Fire",
                    description: "Take a deep breath in, and then forcefully exhale out of your nose by contracting your abdominal muscles. Inhale passively.",
                    duration: 60, // 1 minute
                    breathPattern: .breathOfFire
                ),
                BreathRoutine(
                    title: "Box Breathing",
                    description: "Inhale for a count of 4, hold for 4, exhale for 4, and hold again for 4.",
                    duration: 300, // 5 minutes
                    breathPattern: .boxBreathing
                )
            ]
        ),
        BreathCategory(
            title: "Anxiety & Panic Management",
            routines: [
                BreathRoutine(
                    title: "Alternate Nostril Breathing (Nadi Shodhana)",
                    description: "Use thumb to close right nostril, inhale through left. Close left with ring finger, exhale through right. Inhale right, exhale left.",
                    duration: 600, // 10 minutes
                    breathPattern: .alternateNostril
                ),
                BreathRoutine(
                    title: "5-5-5 Breathing (Counted Breathing)",
                    description: "Inhale through your nose for a count of 5, hold for 5, then exhale for 5.",
                    duration: 300, // 5 minutes
                    breathPattern: .fiveFiveFive
                ),
                BreathRoutine(
                    title: "Lengthened Exhale Breathing",
                    description: "Inhale slowly through your nose for a count of 4, then exhale through your mouth for a count of 6 or 8.",
                    duration: 300, // 5 minutes
                    breathPattern: .lengthenedExhale
                )
            ]
        ),
        BreathCategory(
            title: "Sleep",
            routines: [
                BreathRoutine(
                    title: "Deep Breathing with Visualization",
                    description: "Inhale deeply and visualize a calm, peaceful place. Exhale slowly, imagining stress and tension leaving your body.",
                    duration: 600, // 10 minutes
                    breathPattern: .deepVisualization
                ),
                BreathRoutine(
                    title: "Coherent Breathing",
                    description: "Breathe in for 5 seconds and out for 5 seconds, maintaining a rhythmic pattern.",
                    duration: 600, // 10 minutes
                    breathPattern: .coherentBreathing
                )
            ]
        ),
        BreathCategory(
            title: "Pain Management",
            routines: [
                BreathRoutine(
                    title: "Slow Body Scan",
                    description: "Inhale deeply and slowly, focusing on each part of your body, starting from your toes and working upward. Visualize relaxing each area with each breath.",
                    duration: 600, // 10 minutes
                    breathPattern: .slowBodyScan
                ),
                BreathRoutine(
                    title: "Mindful Counting",
                    description: "Count as you breathe in and out, keeping your mind focused on the counting to distract from pain.",
                    duration: 600, // 10 minutes
                    breathPattern: .mindfulCounting
                )
            ]
        )
    ]
    
    private func saveQuickAccessRoutines() {
        if let encoded = try? JSONEncoder().encode(quickAccessRoutines) {
            quickAccessData = encoded
        }
    }
    
    private func loadQuickAccessRoutines() {
        if let routines = try? JSONDecoder().decode([BreathRoutine].self, from: quickAccessData) {
            quickAccessRoutines = routines
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    // Quick Access Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .imageScale(.medium)
                                .foregroundColor(.yellow)
                            Text("Your Snack Picks")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(quickAccessRoutines) { routine in
                                    QuickAccessCard(routine: routine) {
                                        if let index = quickAccessRoutines.firstIndex(where: { $0.id == routine.id }) {
                                            quickAccessRoutines.remove(at: index)
                                            saveQuickAccessRoutines()
                                        }
                                    }
                                    .onTapGesture {
                                        selectedRoutine = routine
                                        showingRoutine = true
                                    }
                                }
                                
                                if quickAccessRoutines.count < 3 {
                                    Button(action: {
                                        showingRoutinePicker = true
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "plus.circle.fill")
                                                .imageScale(.large)
                                            Text("Add to Picks")
                                                .font(.subheadline)
                                            Text("(\(quickAccessRoutines.count)/3)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(width: 300, height: 200)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Categories
                    ForEach(categories) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(category.routines) { routine in
                                        RoutineCard(routine: routine)
                                            .frame(width: 300)
                                            .onTapGesture {
                                                selectedRoutine = routine
                                                showingRoutine = true
                                            }
                                            .contextMenu {
                                                if !quickAccessRoutines.contains(where: { $0.id == routine.id })
                                                    && quickAccessRoutines.count < 3 {
                                                    Button(action: {
                                                        quickAccessRoutines.append(routine)
                                                        saveQuickAccessRoutines()
                                                    }) {
                                                        Label("Add to Snack Picks", systemImage: "star.fill")
                                                    }
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // Add divider after each category except the last one
                        if category.id != categories.last?.id {
                            Divider()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Breath Snack")
        }
        .sheet(item: $selectedRoutine) { routine in
            BreathingSessionView(routine: routine)
        }
        .sheet(isPresented: $showingRoutinePicker) {
            RoutinePickerView(
                categories: categories,
                currentPicks: quickAccessRoutines
            ) { selectedRoutine in
                if !quickAccessRoutines.contains(where: { $0.id == selectedRoutine.id })
                    && quickAccessRoutines.count < 3 {
                    quickAccessRoutines.append(selectedRoutine)
                    saveQuickAccessRoutines()
                }
            }
        }
        .onAppear {
            loadQuickAccessRoutines()
        }
    }
}

struct QuickAccessCard: View {
    @State private var animate: Bool = false

    let routine: BreathRoutine
    let onRemove: () -> Void
    
    
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
            return [Color(hex: "447A7A"), Color(hex: "F9E866"), Color(hex: "F1EAB9"), Color(hex: "FF8C8C")]
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
        VStack(spacing: 0) {
            // Gradient Header (70% of height)
            ZStack(alignment: .topTrailing) {
                // Linear Gradient at the base
                Rectangle()
                    .fill(
//                        LinearGradient(colors: gradientColors, startPoint: .bottom, endPoint: .top)
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: animate ? .topTrailing : .topLeading,
                            endPoint: animate ? .bottomLeading : .bottomTrailing
                        )
                    )
                    .frame(height: 140)

                // Radial Gradient on top of the linear gradient
                Rectangle()
                    .fill(
//                        RadialGradient(colors: gradientColors, center: .center, startRadius: 10, endRadius: 70)
                        RadialGradient(
                            colors: gradientColors,
                            center: .center,
                            startRadius: animate ? 10 : 40,
                            endRadius: animate ? 50 : 200
                        )
                    )
                    .blendMode(.colorBurn) // Use blend mode to combine gradients
                    .opacity(0.5) // Adjust opacity of radial gradient
                    .frame(height: 140)

                // Button at the top-right corner
                Button(action: onRemove) {
                    Image(systemName: "star.fill")
                        .imageScale(.medium)
                        .foregroundColor(.yellow)
                        .padding(12)
                }
            }
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 6.0).repeatForever(autoreverses: true)
                ) {
                    animate.toggle()
                }

            }

            // Content Section (30% of height)
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text("\(routine.duration / 60) minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "bolt.fill")
                        .imageScale(.small)
                        .foregroundColor(gradientColors[0])
                }
            }
            .frame(height: 60) // 30% of 200
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
        }
        .frame(width: 300, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 3, x: 0, y: 1)
    }
}

struct BreathRoutine: Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let duration: Int // in seconds
    let breathPattern: BreathPattern
}

enum BreathPattern {
    case diaphragmatic
    case fourSevenEight
    case bellowsBreath
    case breathOfFire
    case boxBreathing
    case alternateNostril
    case fiveFiveFive
    case lengthenedExhale
    case deepVisualization
    case coherentBreathing
    case rhythmicRunning
    case pursedLip
    case slowBodyScan
    case mindfulCounting
}

struct BreathCategory: Identifiable {
    let id = UUID()
    let title: String
    let routines: [BreathRoutine]
}

struct RoutinePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let categories: [BreathCategory]
    let currentPicks: [BreathRoutine]
    let onSelect: (BreathRoutine) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    Section(header: Text(category.title)) {
                        ForEach(category.routines) { routine in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(routine.title)
                                        .font(.headline)
                                    Text("\(routine.duration / 60) minutes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if currentPicks.contains(where: { $0.id == routine.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelect(routine)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add to Picks")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

struct RoutineCard: View {
    @State private var animate: Bool = false
    let routine: BreathRoutine
    
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
            return [Color(hex: "447A7A"), Color(hex: "F9E866"), Color(hex: "F1EAB9"), Color(hex: "FF8C8C")]
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
        VStack(spacing: 0) {
            // Gradient Header (70% of height)
            ZStack(alignment: .topTrailing) {
                // Linear Gradient at the base
                Rectangle()
                    .fill(
//                        LinearGradient(colors: gradientColors, startPoint: .bottom, endPoint: .top)
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: animate ? .topTrailing : .topLeading,
                            endPoint: animate ? .bottomLeading : .bottomTrailing
                        )
                    )
                    .frame(height: 140)

                // Radial Gradient on top of the linear gradient
                Rectangle()
                    .fill(
//                        RadialGradient(colors: gradientColors, center: .center, startRadius: 10, endRadius: 70)
                        RadialGradient(
                            colors: gradientColors,
                            center: .center,
                            startRadius: animate ? 10 : 40,
                            endRadius: animate ? 50 : 200
                        )
                    )
                    .blendMode(.colorBurn) // Use blend mode to combine gradients
                    .opacity(0.5) // Adjust opacity of radial gradient
                    .frame(height: 140)

            }
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 6.0).repeatForever(autoreverses: true)
                ) {
                    animate.toggle()
                }

            }
            
            // Content Section (30% of height)
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(routine.duration / 60) \((routine.duration / 60) == 1 ? "minute" : "minutes")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 60) // 30% of 200
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial)
        }
        .frame(width: 300, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        ) // Enhanced bottom shadow
        .padding(.vertical, 4) // Added padding to make shadow visible
    }
}

// Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension BreathRoutine: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, description, duration, breathPattern
        case color // handle color specially
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(duration, forKey: .duration)
        try container.encode(breathPattern, forKey: .breathPattern)
//      try container.encode(color.description, forKey: .color)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        duration = try container.decode(Int.self, forKey: .duration)
        breathPattern = try container.decode(BreathPattern.self, forKey: .breathPattern)
        /*let colorString*/ _ = try container.decode(String.self, forKey: .color)
//      color = Color(colorString)
    }
}

extension BreathPattern: Codable {}
