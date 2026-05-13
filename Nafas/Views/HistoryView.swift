//
//  HistoryView.swift
//  Nafas — past sessions + lifetime stats.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BreathSession.startedAt, order: .reverse) private var sessions: [BreathSession]

    private var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    private var weekMinutes: Int {
        let cal = Calendar.current
        guard let weekAgo = cal.date(byAdding: .day, value: -7, to: .now) else { return 0 }
        return sessions
            .filter { $0.startedAt >= weekAgo }
            .reduce(0) { $0 + $1.durationSeconds } / 60
    }

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerStats
                        .padding(.horizontal, Theme.Metric.edgePadding)
                        .padding(.top, 8)

                    if sessions.isEmpty {
                        emptyState
                            .padding(.top, 40)
                    } else {
                        sessionsList
                            .padding(.horizontal, Theme.Metric.edgePadding)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("History")
    }

    private var headerStats: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History")
                .font(Theme.Font.title(28))
                .foregroundStyle(Theme.Color.textPrimary)

            HStack(spacing: 10) {
                StatTile(
                    value: "\(weekMinutes)m",
                    label: "This week",
                    iconName: "calendar"
                )
                StatTile(
                    value: "\(totalMinutes)m",
                    label: "All time",
                    iconName: "infinity"
                )
                StatTile(
                    value: "\(sessions.count)",
                    label: "Sessions",
                    iconName: "leaf"
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "wind")
                .font(.system(size: 44, weight: .ultraLight))
                .foregroundStyle(Theme.Color.textMuted)
            Text("No sessions yet")
                .font(Theme.Font.headline(18))
                .foregroundStyle(Theme.Color.textPrimary)
            Text("Complete your first breathing session\nand it will appear here.")
                .font(Theme.Font.body(14))
                .foregroundStyle(Theme.Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var sessionsList: some View {
        VStack(spacing: 10) {
            ForEach(sessions) { session in
                SessionRow(session: session)
            }
        }
    }
}

private struct SessionRow: View {
    let session: BreathSession

    var body: some View {
        let p = session.pattern
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: p.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: p.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(p.name)
                    .font(Theme.Font.headline(16))
                    .foregroundStyle(Theme.Color.textPrimary)
                Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.Font.caption(12))
                    .foregroundStyle(Theme.Color.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(session.durationSeconds / 60)m \(session.durationSeconds % 60)s")
                    .font(Theme.Font.mono(13))
                    .foregroundStyle(Theme.Color.textPrimary)
                Text("\(session.cyclesCompleted) cycles")
                    .font(Theme.Font.caption(11))
                    .foregroundStyle(Theme.Color.textSecondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.Metric.cornerMedium, style: .continuous)
                .fill(Theme.Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Metric.cornerMedium, style: .continuous)
                .stroke(Theme.Color.hairline, lineWidth: 1)
        )
    }
}
