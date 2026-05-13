//
//  Chrome.swift
//  Nafas — small shared UI atoms.
//

import SwiftUI

/// Pill-shaped icon button used in nav bars.
struct CircleIconButton: View {
    let systemName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.Color.textPrimary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Theme.Color.surface)
                        .overlay(Circle().stroke(Theme.Color.hairline, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
    }
}

/// Primary call-to-action button — used for "Begin session".
struct PrimaryButton: View {
    let title: String
    let icon: String?
    var gradient: [Color] = [Color(hex: 0x7DD3FC), Color(hex: 0x818CF8)]
    var action: () -> Void

    init(_ title: String, icon: String? = nil, gradient: [Color]? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        if let gradient { self.gradient = gradient }
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.black.opacity(0.85))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: gradient[0].opacity(0.35), radius: 16, y: 6)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Subtle press animation — scale + opacity dip.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Stat card used on Home and History.
struct StatTile: View {
    let value: String
    let label: String
    var iconName: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let iconName {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.Color.accent)
            }
            Text(value)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Theme.Color.textPrimary)
            Text(label)
                .font(Theme.Font.caption(12))
                .foregroundStyle(Theme.Color.textSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
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
