//
//  NafasApp.swift
//  Nafas — Breathe with intention.
//
//  A meditative breathing companion crafted with SwiftUI.
//

import SwiftUI
import SwiftData

@main
struct NafasApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.dark)
                .tint(Theme.Color.accent)
        }
        .modelContainer(for: BreathSession.self)
    }
}
