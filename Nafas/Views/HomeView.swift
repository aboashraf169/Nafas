//
//  HomeView.swift
//  Nafas — pattern carousel + start CTA.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BreathSession.startedAt, order: .reverse) private var sessions: [BreathSession]

    let onStart: (BreathPattern) -> Void
    let onOpenHistory: () -> Void

    @State private var selectionIndex: Int = 0

    private var selectedPattern: BreathPattern {
        BreathPattern.all[selectionIndex]
    }

    // ----------- Derived stats -----------

    private var todayMinutes: Int {
        let cal = Calendar.current
        let today = sessions.filter { cal.isDateInToday($0.startedAt) }
        return today.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    private var totalSessions: Int { sessions.count }

    private var currentStreak: Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        let buckets = Dictionary(grouping: sessions) {
            cal.startOfDay(for: $0.startedAt)
        }
        while buckets[day] != nil {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    var body: some View {
        ZStack {
            AmbientBackground(gradient: selectedPattern.gradient)
                .animation(.easeInOut(duration: 0.6), value: selectionIndex)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, Theme.Metric.edgePadding)
                    .padding(.top, 8)

                Spacer(minLength: 12)

                greeting
                    .padding(.horizontal, Theme.Metric.edgePadding)

                Spacer(minLength: 18)

                carousel
                    .padding(.bottom, 18)

                cyclesStepper
                    .padding(.horizontal, Theme.Metric.edgePadding)
                    .padding(.bottom, 14)

                statsRow
                    .padding(.horizontal, Theme.Metric.edgePadding)
                    .padding(.bottom, 18)

                PrimaryButton(
                    "Begin session",
                    icon: "play.fill",
                    gradient: selectedPattern.gradient
                ) {
                    store.selectedPatternId = selectedPattern.id
                    onStart(selectedPattern)
                }
                .padding(.horizontal, Theme.Metric.edgePadding)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            if let idx = BreathPattern.all.firstIndex(where: { $0.id == store.selectedPatternId }) {
                selectionIndex = idx
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Nafas")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.Color.textPrimary)
                Text("نَفَس")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Theme.Color.textMuted)
            }
            Spacer()
            CircleIconButton(systemName: "clock.arrow.circlepath") {
                onOpenHistory()
            }
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(timeBasedGreeting)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.Color.textSecondary)
                .textCase(.uppercase)
                .tracking(1.2)

            Text("Take a moment\nto breathe.")
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var carousel: some View {
        TabView(selection: $selectionIndex) {
            ForEach(Array(BreathPattern.all.enumerated()), id: \.offset) { idx, pattern in
                PatternCard(pattern: pattern, isSelected: idx == selectionIndex)
                    .padding(.horizontal, Theme.Metric.edgePadding)
                    .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .frame(height: 380)
    }

    private var cyclesStepper: some View {
        HStack {
            Text("Cycles")
                .font(Theme.Font.headline(15))
                .foregroundStyle(Theme.Color.textSecondary)
            Spacer()
            HStack(spacing: 14) {
                Button {
                    if store.sessionCycles > 1 { store.sessionCycles -= 1 }
                    Haptics.shared.tick()
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.Color.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Theme.Color.surface))
                        .overlay(Circle().stroke(Theme.Color.hairline, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())

                Text("\(store.sessionCycles)")
                    .font(Theme.Font.mono(18))
                    .foregroundStyle(Theme.Color.textPrimary)
                    .frame(minWidth: 32)
                    .contentTransition(.numericText())

                Button {
                    if store.sessionCycles < 30 { store.sessionCycles += 1 }
                    Haptics.shared.tick()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.Color.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Theme.Color.surface))
                        .overlay(Circle().stroke(Theme.Color.hairline, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: Theme.Metric.cornerMedium, style: .continuous)
                .fill(Theme.Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Metric.cornerMedium, style: .continuous)
                .stroke(Theme.Color.hairline, lineWidth: 1)
        )
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatTile(
                value: "\(todayMinutes)m",
                label: "Today",
                iconName: "sun.max.fill"
            )
            StatTile(
                value: "\(currentStreak)",
                label: "Streak",
                iconName: "flame.fill"
            )
            StatTile(
                value: "\(totalSessions)",
                label: "Sessions",
                iconName: "infinity"
            )
        }
    }

    // MARK: - Helpers

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Good night"
        }
    }
}
