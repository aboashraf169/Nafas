//
//  PatternCard.swift
//  Nafas
//

import SwiftUI

/// A horizontally-paged card representing one breath pattern.
struct PatternCard: View {
    let pattern: BreathPattern
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Top row: icon + arabic name
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: pattern.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: pattern.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(pattern.arabicName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Theme.Color.textSecondary)
                    .environment(\.layoutDirection, .rightToLeft)
            }

            Spacer(minLength: 4)

            // Title block
            VStack(alignment: .leading, spacing: 6) {
                Text(pattern.name)
                    .font(Theme.Font.title(34))
                    .foregroundStyle(Theme.Color.textPrimary)

                Text(pattern.subtitle)
                    .font(Theme.Font.headline(15))
                    .foregroundStyle(Theme.Color.textSecondary)
            }

            // Pattern rhythm chips
            HStack(spacing: 6) {
                ForEach(Array(pattern.steps.enumerated()), id: \.offset) { _, step in
                    Text("\(Int(step.duration))")
                        .font(Theme.Font.mono(12))
                        .foregroundStyle(Theme.Color.textSecondary)
                        .frame(width: 28, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(Theme.Color.hairline, lineWidth: 1)
                        )
                }
                Text(phaseLabel)
                    .font(Theme.Font.caption(11))
                    .foregroundStyle(Theme.Color.textMuted)
                    .padding(.leading, 4)
            }

            Text(pattern.detail)
                .font(Theme.Font.body(13))
                .foregroundStyle(Theme.Color.textSecondary)
                .lineSpacing(4)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 340)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Metric.cornerLarge, style: .continuous)
                    .fill(Theme.Color.surface)

                // Subtle gradient sheen across the card.
                RoundedRectangle(cornerRadius: Theme.Metric.cornerLarge, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                pattern.gradient[0].opacity(0.20),
                                pattern.gradient.last?.opacity(0.06) ?? .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Metric.cornerLarge, style: .continuous)
                .stroke(
                    isSelected
                        ? pattern.gradient[0].opacity(0.6)
                        : Theme.Color.hairline,
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
        .shadow(
            color: pattern.gradient[0].opacity(isSelected ? 0.35 : 0.10),
            radius: isSelected ? 30 : 12,
            y: 10
        )
        .animation(.easeOut(duration: 0.25), value: isSelected)
    }

    private var phaseLabel: String {
        // "in · hold · out · hold" etc.
        pattern.steps
            .map { step -> String in
                switch step.phase {
                case .inhale:  return "in"
                case .holdIn:  return "hold"
                case .exhale:  return "out"
                case .holdOut: return "hold"
                }
            }
            .joined(separator: " · ")
    }
}
