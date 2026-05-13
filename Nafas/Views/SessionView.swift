//
//  SessionView.swift
//  Nafas — the active, full-screen breathing session.
//
//  The animation engine is driven by a single phase timer. Each time we
//  advance phases we kick off a SwiftUI animation of the matching duration
//  AND a CoreHaptic curve of the same duration — so the orb's expansion
//  and the haptic swell are precisely synchronized.
//

import SwiftUI
import SwiftData

struct SessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppStore.self) private var store

    let pattern: BreathPattern

    // ----- Drive state -----
    @State private var currentStepIndex = 0
    @State private var orbScale: CGFloat = 0.42
    @State private var phaseElapsed: Double = 0
    @State private var phaseStartedAt: Date?
    @State private var cyclesCompleted = 0
    @State private var totalElapsed: Double = 0
    @State private var isPaused = false
    @State private var hasCompleted = false
    @State private var sessionStartedAt = Date.now
    @State private var prepareCountdown: Int = 3   // 3-2-1 lead-in
    @State private var isPreparing = true
    @State private var prepareTask: Task<Void, Never>?

    // ----- Derived -----
    private var currentStep: (phase: BreathPhase, duration: Double) {
        pattern.steps[currentStepIndex % pattern.steps.count]
    }

    private var totalCycles: Int { store.sessionCycles }

    private var progress: Double {
        let totalDuration = pattern.cycleDuration * Double(totalCycles)
        guard totalDuration > 0 else { return 0 }
        return min(1, totalElapsed / totalDuration)
    }

    private var phaseRemaining: Int {
        max(0, Int(ceil(currentStep.duration - phaseElapsed)))
    }

    var body: some View {
        ZStack {
            AmbientBackground(gradient: pattern.gradient)

            // Top bar (close + cycle counter)
            VStack {
                topBar
                    .padding(.horizontal, Theme.Metric.edgePadding)
                    .padding(.top, 8)
                Spacer()
            }

            // Center — orb + instructions
            VStack(spacing: 36) {
                Spacer()

                BreathOrb(
                    scale: orbScale,
                    gradient: pattern.gradient,
                    progress: progress
                )
                .overlay(centerLabel)

                instructionsBlock

                Spacer()
                Spacer()
            }

            // Bottom — pause/skip controls
            VStack {
                Spacer()
                controlsRow
                    .padding(.horizontal, Theme.Metric.edgePadding)
                    .padding(.bottom, 36)
            }

            if hasCompleted {
                completionOverlay
                    .transition(.opacity)
            }
        }
        .onAppear { startPrepareCountdown() }
        .onDisappear {
            Haptics.shared.stopContinuous()
            prepareTask?.cancel()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Pause if app goes background mid-session.
            if newPhase != .active, !hasCompleted, !isPreparing {
                pause()
            }
        }
        .onReceive(Timer.publish(every: 1/30, on: .main, in: .common).autoconnect()) { _ in
            tick()
        }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack {
            CircleIconButton(systemName: "xmark") {
                endSession(saveProgress: !hasCompleted)
                dismiss()
            }
            Spacer()
            VStack(spacing: 2) {
                Text(pattern.name.uppercased())
                    .font(Theme.Font.caption(11))
                    .foregroundStyle(Theme.Color.textSecondary)
                    .tracking(1.4)
                Text("Cycle \(min(cyclesCompleted + 1, totalCycles)) of \(totalCycles)")
                    .font(Theme.Font.headline(15))
                    .foregroundStyle(Theme.Color.textPrimary)
                    .contentTransition(.numericText())
            }
            Spacer()
            CircleIconButton(systemName: store.hapticsEnabled ? "waveform" : "waveform.slash") {
                store.hapticsEnabled.toggle()
                Haptics.shared.enabled = store.hapticsEnabled
                Haptics.shared.tick()
            }
        }
    }

    private var instructionsBlock: some View {
        VStack(spacing: 10) {
            Text(isPreparing ? "Get comfortable" : currentStep.phase.instruction)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Theme.Color.textPrimary)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.4), value: currentStep.phase)
                .animation(.easeInOut(duration: 0.4), value: isPreparing)

            Text(isPreparing ? "Beginning in \(prepareCountdown)" : pattern.arabicName)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Theme.Color.textMuted)
        }
    }

    private var centerLabel: some View {
        Group {
            if isPreparing {
                Text("\(prepareCountdown)")
                    .font(.system(size: 64, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.9))
                    .contentTransition(.numericText())
            } else {
                Text("\(phaseRemaining)")
                    .font(.system(size: 64, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.92))
                    .contentTransition(.numericText())
            }
        }
    }

    private var controlsRow: some View {
        HStack(spacing: 14) {
            Button {
                isPaused ? resume() : pause()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(isPaused ? "Resume" : "Pause")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Theme.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Capsule().fill(Theme.Color.surface))
                .overlay(Capsule().stroke(Theme.Color.hairline, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(isPreparing)
            .opacity(isPreparing ? 0.5 : 1)
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: pattern.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .shadow(color: pattern.gradient[0].opacity(0.6), radius: 24)

                VStack(spacing: 8) {
                    Text("Well done")
                        .font(Theme.Font.title(28))
                        .foregroundStyle(Theme.Color.textPrimary)
                    Text("\(cyclesCompleted) cycles · \(Int(totalElapsed))s")
                        .font(Theme.Font.body(15))
                        .foregroundStyle(Theme.Color.textSecondary)
                }

                PrimaryButton("Done", icon: "checkmark", gradient: pattern.gradient) {
                    dismiss()
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: Theme.Metric.cornerLarge, style: .continuous)
                    .fill(Theme.Color.surfaceRaised)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Metric.cornerLarge, style: .continuous)
                    .stroke(Theme.Color.hairline, lineWidth: 1)
            )
        }
    }

    // MARK: - Engine

    private func startPrepareCountdown() {
        Haptics.shared.enabled = store.hapticsEnabled
        prepareTask = Task { @MainActor in
            for n in [3, 2, 1] {
                prepareCountdown = n
                Haptics.shared.tick(intensity: 0.4)
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
            }
            isPreparing = false
            beginPhase()
        }
    }

    private func beginPhase() {
        let step = currentStep
        phaseStartedAt = .now
        phaseElapsed = 0

        switch step.phase {
        case .inhale:
            withAnimation(.easeInOut(duration: step.duration)) {
                orbScale = step.phase.targetScale
            }
            Haptics.shared.tick(intensity: 0.5)
            Haptics.shared.breath(duration: step.duration, rising: true)
        case .exhale:
            withAnimation(.easeInOut(duration: step.duration)) {
                orbScale = step.phase.targetScale
            }
            Haptics.shared.tick(intensity: 0.5)
            Haptics.shared.breath(duration: step.duration, rising: false)
        case .holdIn, .holdOut:
            // No size change, but a soft tick announces the hold.
            Haptics.shared.hold()
        }
    }

    private func tick() {
        guard !isPreparing, !isPaused, !hasCompleted, let startedAt = phaseStartedAt else { return }

        let elapsed = Date.now.timeIntervalSince(startedAt)
        phaseElapsed = elapsed
        totalElapsed += 1.0 / 30.0

        if elapsed >= currentStep.duration {
            advancePhase()
        }
    }

    private func advancePhase() {
        let wasLastPhaseInCycle = currentStepIndex == pattern.steps.count - 1
        currentStepIndex += 1

        if wasLastPhaseInCycle {
            cyclesCompleted += 1
            if cyclesCompleted >= totalCycles {
                complete()
                return
            }
            currentStepIndex = 0   // wrap
        }
        beginPhase()
    }

    private func pause() {
        isPaused = true
        Haptics.shared.stopContinuous()
        // Freeze the current animation by re-applying the current orbScale without animation.
        withAnimation(.none) { orbScale = orbScale }
    }

    private func resume() {
        guard isPaused else { return }
        isPaused = false
        // Restart current phase from where it left off — simplest correct behavior.
        let remaining = max(0.1, currentStep.duration - phaseElapsed)
        phaseStartedAt = Date.now.addingTimeInterval(-(currentStep.duration - remaining))

        let step = currentStep
        switch step.phase {
        case .inhale:
            withAnimation(.easeInOut(duration: remaining)) { orbScale = step.phase.targetScale }
            Haptics.shared.breath(duration: remaining, rising: true)
        case .exhale:
            withAnimation(.easeInOut(duration: remaining)) { orbScale = step.phase.targetScale }
            Haptics.shared.breath(duration: remaining, rising: false)
        case .holdIn, .holdOut:
            break
        }
    }

    private func complete() {
        guard !hasCompleted else { return }
        hasCompleted = true
        Haptics.shared.stopContinuous()
        Haptics.shared.celebrate()
        endSession(saveProgress: true)
        withAnimation(.spring(duration: 0.5)) { /* triggers overlay */ }
    }

    private func endSession(saveProgress: Bool) {
        guard saveProgress, cyclesCompleted > 0 else { return }
        let session = BreathSession(
            patternId: pattern.id,
            startedAt: sessionStartedAt,
            durationSeconds: Int(totalElapsed),
            cyclesCompleted: cyclesCompleted
        )
        modelContext.insert(session)
        try? modelContext.save()
    }
}
