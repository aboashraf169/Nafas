//
//  BreathPattern.swift
//  Nafas
//

import SwiftUI

/// A single phase of the breath cycle (in / hold / out / hold).
enum BreathPhase: String, CaseIterable, Identifiable, Hashable {
    case inhale
    case holdIn
    case exhale
    case holdOut

    var id: String { rawValue }

    /// Localized user-facing instruction.
    var instruction: String {
        switch self {
        case .inhale:  return "Breathe in"
        case .holdIn:  return "Hold"
        case .exhale:  return "Breathe out"
        case .holdOut: return "Hold"
        }
    }

    /// Where the breath circle should sit, normalized 0…1, at the END of the phase.
    var targetScale: CGFloat {
        switch self {
        case .inhale:  return 1.0
        case .holdIn:  return 1.0
        case .exhale:  return 0.42
        case .holdOut: return 0.42
        }
    }
}

/// A breathing pattern is an ordered series of (phase, duration) pairs.
struct BreathPattern: Identifiable, Hashable {
    let id: String
    let name: String
    let arabicName: String
    let subtitle: String
    let detail: String
    let symbol: String
    let gradient: [Color]
    /// Each step is the phase plus the duration (seconds) to spend in it.
    let steps: [(phase: BreathPhase, duration: Double)]

    var cycleDuration: Double { steps.reduce(0) { $0 + $1.duration } }

    static func == (lhs: BreathPattern, rhs: BreathPattern) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension BreathPattern {
    /// 4 · 4 · 4 · 4 — Navy SEALs box breathing for sharp, present focus.
    static let box = BreathPattern(
        id: "box",
        name: "Box",
        arabicName: "تركيز",
        subtitle: "Sharpen your focus",
        detail: "Equal four-count inhale, hold, exhale, hold. Used by pilots and athletes to settle the mind before performance.",
        symbol: "square",
        gradient: [Color(hex: 0x4A6FE3), Color(hex: 0x6E4AE3)],
        steps: [
            (.inhale, 4), (.holdIn, 4), (.exhale, 4), (.holdOut, 4)
        ]
    )

    /// 4 · 7 · 8 — Dr. Weil's relaxing breath, classic pre-sleep technique.
    static let calm = BreathPattern(
        id: "calm",
        name: "Calm",
        arabicName: "سَكينة",
        subtitle: "Drift into rest",
        detail: "A long, slow exhale signals the body it is safe. Excellent before sleep or after a stressful moment.",
        symbol: "moon.stars",
        gradient: [Color(hex: 0xEC4899), Color(hex: 0xF43F5E)],
        steps: [
            (.inhale, 4), (.holdIn, 7), (.exhale, 8)
        ]
    )

    /// 5 · 5 — Coherent breathing, balances the autonomic nervous system.
    static let balance = BreathPattern(
        id: "balance",
        name: "Balance",
        arabicName: "توازن",
        subtitle: "Find your center",
        detail: "Five-second inhale, five-second exhale at six breaths per minute — the resonant rate of the heart.",
        symbol: "circle.grid.cross",
        gradient: [Color(hex: 0x059669), Color(hex: 0x0EA5E9)],
        steps: [
            (.inhale, 5), (.exhale, 5)
        ]
    )

    /// 6 · 2 · 4 — Brisk, energizing breath to start the day.
    static let energize = BreathPattern(
        id: "energize",
        name: "Energize",
        arabicName: "نَشاط",
        subtitle: "Wake the body",
        detail: "A longer inhale than exhale gently lifts heart rate — bright, clean energy without caffeine.",
        symbol: "sun.max",
        gradient: [Color(hex: 0xF59E0B), Color(hex: 0xEF4444)],
        steps: [
            (.inhale, 6), (.holdIn, 2), (.exhale, 4)
        ]
    )

    static let all: [BreathPattern] = [.box, .calm, .balance, .energize]
}
