//
//  ControlsSettingsView.swift
//  Neotris
//
//  Created by Rishi Singh on 14/04/26.
//

#if os(macOS)
import SwiftUI
import AppKit
import TipKit

struct ControlsSettingsView: View {
    @Environment(GameViewModel.self) private var viewModel

    /// Which action + slot is being recorded right now.
    @State private var recording: RecordingState?
    /// The temporary NSEvent monitor active during recording.
    @State private var keyMonitor: Any?

    private let controlsDetailTip = KeyboardShortcutsDetailTip()

    var body: some View {
        ScrollView {
            TipView(controlsDetailTip)
                .padding([.horizontal, .top])
            MacCustomSection(
                header: "Keyboard Controls",
                footer: "Each action supports up to \(maxBindingsPerAction) shortcuts. Click a badge to reassign it, or press Escape to cancel."
            ) {
                ForEach(Array(GameAction.allCases.enumerated()), id: \.element.rawValue) { offset, action in
                    if offset != 0 {
                        Divider().padding(.vertical, 2)
                    }
                    ActionRow(action: action)
                }
            }
        }
        .onDisappear { stopRecording() }
    }

    // MARK: - Action Row

    @ViewBuilder
    private func ActionRow(action: GameAction) -> some View {
        let activeBindings = viewModel.bindings(for: action)
        let isRecordingThisAction = recording?.action == action
        let conflicts = conflictingActions(for: action)
        let isAtDefault = activeBindings == action.defaultBindings

        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 6) {
                Text(action.displayName)
                    .frame(width: 130, alignment: .leading)

                Spacer()

                // Existing binding badges
                ForEach(Array(activeBindings.enumerated()), id: \.offset) { index, binding in
                    let isThisSlotRecording = isRecordingThisAction
                        && recording?.slot == .replacing(index)

                    if isThisSlotRecording {
                        RecordingBadge()
                    } else {
                        KeyBadge(
                            label: binding.displayString,
                            canRemove: activeBindings.count > 1,
                            onTap: { startRecording(action: action, slot: .replacing(index)) },
                            onRemove: { removeBinding(action: action, at: index) }
                        )
                    }
                }

                // "Adding new" recording indicator (only when + was tapped)
                if isRecordingThisAction && recording?.slot == .adding {
                    RecordingBadge()
                }

                // Cancel — shown during any recording for this action
                if isRecordingThisAction {
                    Button("Cancel") { stopRecording() }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.secondary)
                } else {
                    // Add shortcut button
                    let atMax = activeBindings.count >= maxBindingsPerAction
                    Button {
                        startRecording(action: action, slot: .adding)
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .disabled(atMax)
                    .help(atMax
                          ? "Maximum \(maxBindingsPerAction) shortcuts reached"
                          : "Add another shortcut")

                    // Per-action reset button
                    Button { resetBindings(for: action) } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(isAtDefault ? Color.secondary.opacity(0.35) : .secondary)
                    }
                    .buttonStyle(.borderless)
                    .disabled(isAtDefault)
                    .help("Reset to defaults")
                }
            }

            // Conflict warnings
            if !isRecordingThisAction {
                ForEach(conflicts, id: \.rawValue) { conflicting in
                    Text("⚠ Conflicts with \"\(conflicting.displayName)\"")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func RecordingBadge() -> some View {
        Text("Press any key…")
            .font(.system(.body, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.accentColor, lineWidth: 1.5)
            )
    }

    @ViewBuilder
    private func KeyBadge(
        label: String,
        canRemove: Bool,
        onTap: @escaping () -> Void,
        onRemove: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 2) {
            Button(action: onTap) {
                Text(label)
                    .font(.system(.body, design: .monospaced))
                    .padding(.leading, 10)
                    .padding(.trailing, canRemove ? 4 : 10)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderless)
            .help("Click to reassign")

            if canRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 6)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderless)
                .help("Remove this shortcut")
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
        )
    }

    // MARK: - Recording

    private func startRecording(action: GameAction, slot: RecordingState.Slot) {
        stopRecording()
        recording = RecordingState(action: action, slot: slot)

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Escape cancels recording without saving.
            if event.keyCode == 53 {
                self.stopRecording()
                return nil
            }

            let mods = event.modifierFlags
                .intersection(KeyBinding.userModifierMask)
                .rawValue
            let newBinding = KeyBinding(keyCode: event.keyCode, modifierFlags: mods)
            var current = self.viewModel.bindings(for: action)

            switch slot {
            case .replacing(let idx):
                if current.indices.contains(idx) {
                    current[idx] = newBinding
                }
            case .adding:
                if current.count < maxBindingsPerAction {
                    current.append(newBinding)
                }
            }

            self.viewModel.keyBindings[action.rawValue] = current
            self.stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
        recording = nil
    }

    // MARK: - Remove / Reset

    private func removeBinding(action: GameAction, at index: Int) {
        var current = viewModel.bindings(for: action)
        guard current.indices.contains(index), current.count > 1 else { return }
        current.remove(at: index)
        viewModel.keyBindings[action.rawValue] = current
    }

    private func resetBindings(for action: GameAction) {
        viewModel.keyBindings[action.rawValue] = action.defaultBindings
    }

    // MARK: - Conflict Detection

    /// Returns all OTHER actions that share at least one binding with this action.
    private func conflictingActions(for action: GameAction) -> [GameAction] {
        let theseBindings = viewModel.bindings(for: action)
        return GameAction.allCases.filter { other in
            guard other != action else { return false }
            return viewModel.bindings(for: other).contains { theseBindings.contains($0) }
        }
    }
}

// MARK: - Supporting types

private struct RecordingState: Equatable {
    let action: GameAction
    let slot: Slot

    enum Slot: Equatable {
        case replacing(Int)
        case adding
    }
}

#Preview {
    ControlsSettingsView()
        .environment(GameViewModel())
}
#endif
