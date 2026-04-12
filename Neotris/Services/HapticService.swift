//
//  HapticService.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import CoreHaptics

final class HapticService {
    private var hapticEngine: CHHapticEngine?

    // MARK: - Lifecycle

    func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            hapticEngine?.resetHandler = { [weak self] in
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
            hapticEngine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
        } catch {
            print("Failed to initialize haptic engine: \(error)")
        }
    }

    func stop() {
        hapticEngine?.stop()
    }

    // MARK: - Playback

    func playMovement(enabled: Bool) {
        play(intensity: 0.3, sharpness: 0.5, enabled: enabled)
    }

    func playRotation(enabled: Bool) {
        play(intensity: 0.4, sharpness: 0.7, enabled: enabled)
    }

    func playHardDrop(enabled: Bool) {
        play(intensity: 0.8, sharpness: 0.9, duration: 0.2, enabled: enabled)
    }

    func playLineClear(count: Int, enabled: Bool) {
        switch count {
        case 4:
            play(intensity: 1.0, sharpness: 1.0, duration: 0.3, enabled: enabled)
        case 2...3:
            play(intensity: 0.7, sharpness: 0.8, duration: 0.2, enabled: enabled)
        default:
            play(intensity: 0.5, sharpness: 0.6, duration: 0.1, enabled: enabled)
        }
    }

    func playLevelUp(enabled: Bool) {
        guard enabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        ensureEngineReady()
        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0.1
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0.2
            )
        ]
        playPattern(events: events)
    }

    func playGameOver(enabled: Bool) {
        guard enabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        ensureEngineReady()
        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0.1
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0.2,
                duration: 0.3
            )
        ]
        playPattern(events: events)
    }

    // MARK: - Private

    private func ensureEngineReady() {
        if hapticEngine == nil {
            prepare()
        }
    }

    private func play(intensity: Float, sharpness: Float, duration: TimeInterval = 0.1, enabled: Bool) {
        guard enabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        ensureEngineReady()
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )
        playPattern(events: [event])
    }

    private func playPattern(events: [CHHapticEvent]) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}
