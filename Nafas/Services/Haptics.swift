//
//  Haptics.swift
//  Nafas — breath-synced tactile feedback.
//
//  Uses CoreHaptics for a continuous, swelling vibration during inhale/exhale
//  and a softer tick for phase boundaries. Gracefully no-ops on devices
//  without haptics or when the user disables them.
//

import CoreHaptics
import UIKit

@MainActor
final class Haptics {
    static let shared = Haptics()

    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    var enabled: Bool = true

    private init() { prepare() }

    private func prepare() {
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { [weak self] _ in
                try? self?.engine?.start()
            }
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            try engine?.start()
        } catch {
            engine = nil
        }
    }

    // MARK: - Public API

    /// Sharp boundary tick (phase transitions).
    func tick(intensity: Float = 0.6) {
        guard enabled else { return }
        guard supportsHaptics, let engine else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                .init(parameterID: .hapticIntensity, value: intensity),
                .init(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0
        )
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            try engine.makePlayer(with: pattern).start(atTime: 0)
        } catch { /* silent */ }
    }

    /// A continuous haptic that swells over `duration` seconds.
    /// `rising = true` ramps from soft to firm (matches inhale).
    /// `rising = false` recedes (matches exhale).
    func breath(duration: Double, rising: Bool) {
        guard enabled, supportsHaptics, let engine else { return }
        stopContinuous()

        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: rising
                ? [.init(relativeTime: 0, value: 0.05),
                   .init(relativeTime: duration, value: 0.45)]
                : [.init(relativeTime: 0, value: 0.45),
                   .init(relativeTime: duration, value: 0.05)],
            relativeTime: 0
        )

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 0.25),
                .init(parameterID: .hapticSharpness, value: 0.2)
            ],
            relativeTime: 0,
            duration: duration
        )

        do {
            let pattern = try CHHapticPattern(
                events: [event],
                parameterCurves: [intensityCurve]
            )
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: 0)
        } catch { /* silent */ }
    }

    /// Hold-phase: very subtle pulse.
    func hold() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.4)
    }

    /// Session-complete celebratory pattern.
    func celebrate() {
        guard enabled else { return }
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
    }

    func stopContinuous() {
        try? continuousPlayer?.stop(atTime: 0)
        continuousPlayer = nil
    }
}
