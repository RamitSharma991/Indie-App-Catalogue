//
//  CalendarView.swift
//  Breath Snack
//
//  Created by Ramit Sharma on 11/11/24.
//

import SwiftUI
import Charts

struct CalendarView: View {
    @StateObject private var sessionManager = SessionManager()
    @State private var selectedTimeRange = TimeRange.week
    private var maxDuration: Int {
        let maxValue = groupedSessions.flatMap { $0.routines }.map { $0.duration }.max() ?? 0
        return max(maxValue + 5, 30) // Add padding and ensure minimum scale
    }
    
    enum TimeRange: String, CaseIterable {
        case week = "D"
        case month = "M"
        case year = "Y"
        case all = "All"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress Section
                    HStack(spacing: 20) {
                        ProgressCard(
                            title: "Total Routines",
                            value: "\(sessionManager.sessions.count)",
                            icon: "figure.mind.and.body"
                        )
                        
                        ProgressCard(
                            title: "Time Elapsed",
                            value: "\(totalMinutes) min",
                            icon: "clock.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Activity Chart Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Activity")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Picker("Time Range", selection: $selectedTimeRange) {
                                ForEach(TimeRange.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                        }
                        .padding(.horizontal)
                        
                        // Chart
                        Chart {
                            ForEach(groupedSessions) { group in
                                ForEach(group.routines) { routine in
                                    LineMark(
                                        x: .value("Date", group.date),
                                        y: .value("Duration", max(0, routine.duration)) // Ensure no negative values
                                    )
                                    .foregroundStyle(getColorForRoutine(routine.title))
                                    .interpolationMethod(.monotone) // Changed from catmullRom to prevent overshooting
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let date = value.as(Date.self) {
                                        switch selectedTimeRange {
                                        case .week:
                                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                        case .month:
                                            Text(date.formatted(.dateTime.day()))
                                        case .year:
                                            Text(date.formatted(.dateTime.month(.abbreviated)))
                                        case .all:
                                            Text(date.formatted(.dateTime.month(.abbreviated)))
                                        }
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let minutes = value.as(Int.self) {
                                        Text("\(max(0, minutes))m") // Ensure no negative values in labels
                                    }
                                }
                            }
                        }
                        .chartYScale(domain: 0...maxDuration) // Add fixed Y-axis scale
                        .chartPlotStyle { plotArea in
                            plotArea
                                .background(Color(.systemGray6).opacity(0.5))
                        }
                        .frame(height: 220)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                
                        // Legend
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(uniqueRoutineTypes, id: \.self) { type in
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(getColorForRoutine(type))
                                            .frame(width: 8, height: 8)
                                        Text(type)
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    Divider()
                    
                    // Recent Sessions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Sessions")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(sessionManager.sessions.prefix(5)) { session in
                            RecentSessionCard(session: session)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Progress")
        }
    }
    
    private var totalMinutes: Int {
        sessionManager.sessions.reduce(0) { total, session in
            total + (session.duration / 60)
        }
    }

    
    private var uniqueRoutineTypes: [String] {
        Array(Set(sessionManager.sessions.map { $0.routineTitle })).sorted()
    }
    
    private func getColorForRoutine(_ type: String) -> Color {
        switch type {
        case "Diaphragmatic (Abdominal) Breathing":
            return Color(hex: "A5CAD2")
        case "4-7-8 Breathing (Relaxing Breath)":
            return Color(hex: "8A5082")
        case "Bellows Breath (Bhastrika)":
            return Color(hex: "438BD3")
        case "Breath of Fire":
            return Color(hex: "EE4392")
        case "Box Breathing":
            return Color(hex: "004E99")
        case "Alternate Nostril Breathing (Nadi Shodhana)":
            return Color(hex: "9FA5D5")
        case "5-5-5 Breathing (Counted Breathing)":
            return Color(hex: "D9AAC7")
        case "Lengthened Exhale Breathing":
            return Color(hex: "451E61")
        case "Deep Breathing with Visualization":
            return Color(hex: "447A7A")
        case "Coherent Breathing":
            return Color(hex: "F1EAB9")
        case "Rhythmic Running Breath":
            return Color(hex: "D8B5FF")
        case "Pursed-Lip Breathing":
            return Color(hex: "2B4C59")
        case "Slow Body Scan":
            return Color(hex: "FFA166")
        case "Mindful Counting":
            return Color(hex: "A2C374")
        default:
            return Color(hex: "A5CAD2")
        }
    }
    
    private var groupedSessions: [GroupedSession] {
        let calendar = Calendar.current
        let now = Date()
        
        // Filter sessions based on selected time range
        let filteredSessions = sessionManager.sessions.filter { session in
            switch selectedTimeRange {
            case .week:
                guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return false }
                return session.date >= weekAgo
            case .month:
                guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return false }
                return session.date >= monthAgo
            case .year:
                guard let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return false }
                return session.date >= yearAgo
            case .all:
                return true
            }
        }
        
        // Group sessions by appropriate time interval
        let groupedByDate = Dictionary(grouping: filteredSessions) { session in
            switch selectedTimeRange {
            case .week:
                return calendar.startOfDay(for: session.date)
            case .month:
                return calendar.startOfDay(for: session.date)
            case .year:
                // Group by month
                let components = calendar.dateComponents([.year, .month], from: session.date)
                return calendar.date(from: components) ?? session.date
            case .all:
                // Group by month
                let components = calendar.dateComponents([.year, .month], from: session.date)
                return calendar.date(from: components) ?? session.date
            }
        }
        
        // Convert to GroupedSession format and aggregate durations
        var result: [GroupedSession] = []
        for (date, sessions) in groupedByDate {
            // Group sessions by routine title and sum their durations
            let routineGroups = Dictionary(grouping: sessions) { $0.routineTitle }
            let routineData = routineGroups.map { title, sessions in
                RoutineData(
                    title: title,
                    duration: sessions.reduce(0) { $0 + ($1.duration / 60) }
                )
            }
            result.append(GroupedSession(date: date, routines: routineData))
        }
        
        return result.sorted(by: { $0.date < $1.date })
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RecentSessionCard: View {
    let session: BreathSession
    private func getColorForRoutine(_ type: String) -> Color {
        switch type {
        case "Diaphragmatic (Abdominal) Breathing":
            return Color(hex: "A5CAD2")
        case "4-7-8 Breathing (Relaxing Breath)":
            return Color(hex: "8A5082")
        case "Bellows Breath (Bhastrika)":
            return Color(hex: "438BD3")
        case "Breath of Fire":
            return Color(hex: "EE4392")
        case "Box Breathing":
            return Color(hex: "004E99")
        case "Alternate Nostril Breathing (Nadi Shodhana)":
            return Color(hex: "9FA5D5")
        case "5-5-5 Breathing (Counted Breathing)":
            return Color(hex: "D9AAC7")
        case "Lengthened Exhale Breathing":
            return Color(hex: "451E61")
        case "Deep Breathing with Visualization":
            return Color(hex: "447A7A")
        case "Coherent Breathing":
            return Color(hex: "F1EAB9")
        case "Rhythmic Running Breath":
            return Color(hex: "D8B5FF")
        case "Pursed-Lip Breathing":
            return Color(hex: "2B4C59")
        case "Slow Body Scan":
            return Color(hex: "FFA166")
        case "Mindful Counting":
            return Color(hex: "A2C374")
        default:
            return Color(hex: "A5CAD2")
        }
    }

    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(getColorForRoutine(session.routineTitle))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "wind")
                        .foregroundStyle(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.routineTitle)
                    .font(.headline)
                
                Text("\(session.duration / 60) \((session.duration / 60) == 1 ? "minute" : "minutes")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(session.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct GroupedSession: Identifiable {
    let id = UUID()
    let date: Date
    let routines: [RoutineData]
}

struct RoutineData: Identifiable {
    let id = UUID()
    let title: String
    let duration: Int
}
