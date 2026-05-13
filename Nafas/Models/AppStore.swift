//
//  AppStore.swift
//  Nafas
//

import Foundation
import Observation

/// Lightweight global store for user preferences.
/// Persisted via UserDefaults — small surface, no need for SwiftData here.
@Observable
final class AppStore {
    var selectedPatternId: String {
        didSet { UserDefaults.standard.set(selectedPatternId, forKey: Keys.pattern) }
    }

    var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: Keys.haptics) }
    }

    var sessionCycles: Int {
        didSet { UserDefaults.standard.set(sessionCycles, forKey: Keys.cycles) }
    }

    init() {
        let d = UserDefaults.standard
        self.selectedPatternId = d.string(forKey: Keys.pattern) ?? BreathPattern.box.id
        self.hapticsEnabled = d.object(forKey: Keys.haptics) as? Bool ?? true
        self.sessionCycles = max(1, d.object(forKey: Keys.cycles) as? Int ?? 8)
    }

    var selectedPattern: BreathPattern {
        BreathPattern.all.first { $0.id == selectedPatternId } ?? .box
    }

    private enum Keys {
        static let pattern = "nafas.selectedPatternId"
        static let haptics = "nafas.hapticsEnabled"
        static let cycles  = "nafas.sessionCycles"
    }
}
