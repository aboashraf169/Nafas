//
//  RootView.swift
//  Nafas — orchestrates navigation between Home and the active Session.
//

import SwiftUI

struct RootView: View {
    @Environment(AppStore.self) private var store
    @State private var activeSessionPattern: BreathPattern?
    @State private var showingHistory = false

    var body: some View {
        ZStack {
            HomeView(
                onStart: { pattern in
                    activeSessionPattern = pattern
                },
                onOpenHistory: { showingHistory = true }
            )
        }
        .fullScreenCover(item: $activeSessionPattern) { pattern in
            SessionView(pattern: pattern)
                .environment(store)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Theme.Color.background)
        }
    }
}

