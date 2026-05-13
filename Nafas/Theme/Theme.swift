//
//  Theme.swift
//  Nafas — design tokens. Centralized so the entire app speaks one visual language.
//

import SwiftUI

enum Theme {

    // MARK: Colors

    enum Color {
        static let background     = SwiftUI.Color(hex: 0x05060B)
        static let surface        = SwiftUI.Color(hex: 0x0E1018)
        static let surfaceRaised  = SwiftUI.Color(hex: 0x161A26)
        static let accent         = SwiftUI.Color(hex: 0x7DD3FC)   // sky-300
        static let textPrimary    = SwiftUI.Color(hex: 0xF5F7FA)
        static let textSecondary  = SwiftUI.Color(hex: 0x9AA3B2)
        static let textMuted      = SwiftUI.Color(hex: 0x5B6373)
        static let hairline       = SwiftUI.Color.white.opacity(0.06)
    }

    // MARK: Typography

    enum Font {
        static func display(_ size: CGFloat = 56) -> SwiftUI.Font {
            .system(size: size, weight: .ultraLight, design: .default)
                .width(.expanded)
        }
        static func title(_ size: CGFloat = 28) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        static func headline(_ size: CGFloat = 18) -> SwiftUI.Font {
            .system(size: size, weight: .medium, design: .default)
        }
        static func body(_ size: CGFloat = 15) -> SwiftUI.Font {
            .system(size: size, weight: .regular, design: .default)
        }
        static func caption(_ size: CGFloat = 12) -> SwiftUI.Font {
            .system(size: size, weight: .medium, design: .default)
        }
        static func mono(_ size: CGFloat = 14) -> SwiftUI.Font {
            .system(size: size, weight: .medium, design: .monospaced)
        }
    }

    // MARK: Spacing & radii

    enum Metric {
        static let cornerSmall:  CGFloat = 12
        static let cornerMedium: CGFloat = 20
        static let cornerLarge:  CGFloat = 32
        static let edgePadding:  CGFloat = 20
    }
}

// MARK: - Color helpers

extension Color {
    /// Hex initializer — `Color(hex: 0xFF8800)`.
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Ambient backdrop

/// A deep, slowly-shifting backdrop. Used as the universal background of the app.
struct AmbientBackground: View {
    var gradient: [Color] = [Color(hex: 0x0B1230), Color(hex: 0x14092E)]
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            // Two soft radial glows that drift slowly.
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(gradient[0].opacity(0.55))
                        .frame(width: geo.size.width * 1.1)
                        .blur(radius: 120)
                        .offset(
                            x: -geo.size.width * 0.25 + sin(phase) * 40,
                            y: -geo.size.height * 0.30 + cos(phase * 0.7) * 30
                        )

                    Circle()
                        .fill(gradient[1].opacity(0.50))
                        .frame(width: geo.size.width * 1.0)
                        .blur(radius: 140)
                        .offset(
                            x:  geo.size.width * 0.30 + cos(phase * 0.9) * 40,
                            y:  geo.size.height * 0.35 + sin(phase * 0.6) * 30
                        )
                }
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 24).repeatForever(autoreverses: true)) {
                    phase = .pi
                }
            }

            // Subtle vignette to focus the center.
            RadialGradient(
                colors: [.clear, Theme.Color.background.opacity(0.7)],
                center: .center,
                startRadius: 200,
                endRadius: 600
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}
