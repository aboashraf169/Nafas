//
//  BreathOrb.swift
//  Nafas — the breathing orb. The visual heart of the app.
//

import SwiftUI

/// A soft, glowing orb that scales between two sizes to coach breath rhythm.
struct BreathOrb: View {
    /// 0…1 scale value driven by the session view's animation.
    var scale: CGFloat
    /// Gradient colors taken from the current breath pattern.
    var gradient: [Color]
    /// 0…1 — overall session progress, lights up the progress arc.
    var progress: Double

    var body: some View {
        ZStack {
            // ---------- Outer halo (static, soft glow) ----------
            Circle()
                .fill(
                    RadialGradient(
                        colors: [gradient[0].opacity(0.35), .clear],
                        center: .center,
                        startRadius: 80,
                        endRadius: 220
                    )
                )
                .blur(radius: 30)

            // ---------- Trailing rings (each slightly delayed) ----------
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        gradient[0].opacity(0.16 - Double(i) * 0.04),
                        lineWidth: 1
                    )
                    .frame(width: 260, height: 260)
                    .scaleEffect(scale + CGFloat(i) * 0.04)
            }

            // ---------- Session progress arc ----------
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: gradient + [gradient.first ?? .white],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 290, height: 290)
                .opacity(0.6)
                .animation(.easeInOut(duration: 0.4), value: progress)

            // ---------- Core orb ----------
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 240, height: 240)
                    .shadow(color: gradient[0].opacity(0.7), radius: 40)

                // Inner highlight — gives a glassy, premium feel.
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.0)
                            ],
                            center: .init(x: 0.32, y: 0.28),
                            startRadius: 4,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blendMode(.plusLighter)

                // Subtle ring on the rim of the orb.
                Circle()
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    .frame(width: 240, height: 240)
            }
            .scaleEffect(scale)
        }
        .frame(width: 320, height: 320)
        .compositingGroup()
    }
}
