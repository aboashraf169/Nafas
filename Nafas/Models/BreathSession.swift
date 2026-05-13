//
//  BreathSession.swift
//  Nafas
//

import Foundation
import SwiftData

@Model
final class BreathSession {
    @Attribute(.unique) var id: UUID
    var patternId: String
    var startedAt: Date
    var durationSeconds: Int
    var cyclesCompleted: Int

    init(
        id: UUID = UUID(),
        patternId: String,
        startedAt: Date = .now,
        durationSeconds: Int,
        cyclesCompleted: Int
    ) {
        self.id = id
        self.patternId = patternId
        self.startedAt = startedAt
        self.durationSeconds = durationSeconds
        self.cyclesCompleted = cyclesCompleted
    }

    var pattern: BreathPattern {
        BreathPattern.all.first { $0.id == patternId } ?? .box
    }
}
