import ActivityKit
import AlarmKit
import AppIntents
import SwiftUI

// MARK: - Controls

struct AlarmLiveActivityControls: View {
    let mode: AlarmPresentationState.Mode
    let alarmID: UUID
    let tint: Color
    var spacing: CGFloat = 10
    var buttonSize: CGFloat = 40
    var iconSize: CGFloat = 20

    var body: some View {
        HStack(spacing: spacing) {
            // Play/Pause slot — always occupies the same fixed space so the
            // stop button never shifts when the state changes.
            switch mode {
            case .countdown:
                AlarmLiveActivityCircleButton(
                    systemImage: "pause.fill",
                    intent: PauseIntent(alarmID: alarmID.uuidString),
                    foregroundStyle: tint,
                    backgroundStyle: tint.opacity(0.3),
                    size: buttonSize,
                    iconSize: iconSize
                )
            case .paused:
                AlarmLiveActivityCircleButton(
                    systemImage: "play.fill",
                    intent: ResumeIntent(alarmID: alarmID.uuidString),
                    foregroundStyle: tint,
                    backgroundStyle: tint.opacity(0.3),
                    size: buttonSize,
                    iconSize: iconSize
                )
            default:
                // Alert/unknown: invisible placeholder keeps stop button anchored.
                Color.clear.frame(width: buttonSize, height: buttonSize)
            }

            // Stop button — always visible
            AlarmLiveActivityCircleButton(
                systemImage: "stop.fill",
                intent: StopIntent(alarmID: alarmID.uuidString),
                foregroundStyle: .primary,
                backgroundStyle: .primary.opacity(0.2),
                size: buttonSize,
                iconSize: iconSize
            )
        }
        .liveActivityAnimationsDisabled()
    }
}

// MARK: - Circle Button

struct AlarmLiveActivityCircleButton<I>: View where I: AppIntent {
    let systemImage: String
    let intent: I
    let foregroundStyle: Color
    let backgroundStyle: Color
    var size: CGFloat = 58
    var iconSize: CGFloat = 26

    var body: some View {
        Button(intent: intent) {
            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(foregroundStyle)
                .offset(x: systemImage == "play.fill" ? 1.5 : 0)
                .frame(width: size, height: size)
                .background(backgroundStyle, in: .circle)
        }
        .buttonStyle(.plain)
        .liveActivityAnimationsDisabled()
    }
}

// MARK: - Countdown Text

/// Renders the countdown clock for both running and paused states without jumping.
///
/// Core fix: `timerText` is a computed *value* property that always returns a single
/// `Text` view — not a `@ViewBuilder` switch with different branches. This gives
/// SwiftUI a stable view identity regardless of mode, so no layout shift occurs
/// when toggling play/pause.
struct AlarmCountdownText: View {
    let mode: AlarmPresentationState.Mode
    let emptyText: String
    let font: Font
    var lineLimit: Int = 1
    var minimumScaleFactor: CGFloat = 0.65
    var isCompactIsland: Bool = false

    private var isPaused: Bool {
        if case .paused = mode {
            return true
        }
        return false
    }

    private var remainingSeconds: Int {
        switch mode {
        case .countdown(let countdown):
            return max(0, Int(countdown.fireDate.timeIntervalSince(Date.now)))
        case .paused(let paused):
            return max(0, Int(paused.totalCountdownDuration - paused.previouslyElapsedDuration))
        default:
            return 0
        }
    }

    private var staticTimeString: String {
        let remaining = remainingSeconds
        
        switch mode {
        case .countdown, .paused:
            break
        default:
            return emptyText
        }
        
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        
        if isCompactIsland {
            if remaining >= 600 {
                return "\(remaining / 60)m"
            } else {
                return "\(minutes):\(String(format: "%02d", seconds))"
            }
        }
        
        if hours > 0 {
            return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }

    var body: some View {
        // The main layout element is ALWAYS the static text.
        // This guarantees a perfectly stable bounding box that never jumps.
        Text(verbatim: staticTimeString)
            .font(font)
            .monospacedDigit()
            .lineLimit(lineLimit)
            .minimumScaleFactor(minimumScaleFactor)
            // Hide the text but keep its layout size
            .opacity(0)
            .fixedSize(horizontal: true, vertical: true)
            .overlay(alignment: .leading) {
                // Overlay the visible text
                if isPaused {
                    Text(verbatim: staticTimeString)
                        .font(font)
                        .monospacedDigit()
                        .lineLimit(lineLimit)
                        .minimumScaleFactor(minimumScaleFactor)
                        .fixedSize(horizontal: true, vertical: true)
                } else {
                    if case .countdown(let countdown) = mode {
                        if isCompactIsland && remainingSeconds >= 600 {
                            Text(verbatim: staticTimeString)
                                .font(font)
                                .monospacedDigit()
                                .lineLimit(lineLimit)
                                .minimumScaleFactor(minimumScaleFactor)
                                .fixedSize(horizontal: true, vertical: true)
                        } else if Date.now < countdown.fireDate {
                            #if DEBUG
                            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                                Text(verbatim: staticTimeString)
                                    .font(font)
                                    .monospacedDigit()
                                    .lineLimit(lineLimit)
                                    .minimumScaleFactor(minimumScaleFactor)
                                    .fixedSize(horizontal: true, vertical: true)
                            } else {
                                Text(timerInterval: Date.now...countdown.fireDate, countsDown: true)
                                    .font(font)
                                    .monospacedDigit()
                                    .lineLimit(lineLimit)
                                    .minimumScaleFactor(minimumScaleFactor)
                                    // Provide ample space to prevent truncation/shrinking.
                                    // Because we are in an overlay aligned .leading, the extra width
                                    // harmlessly extends to the right and doesn't push the layout.
                                    .frame(width: 400, alignment: .leading)
                            }
                            #else
                            Text(timerInterval: Date.now...countdown.fireDate, countsDown: true)
                                .font(font)
                                .monospacedDigit()
                                .lineLimit(lineLimit)
                                .minimumScaleFactor(minimumScaleFactor)
                                .frame(width: 400, alignment: .leading)
                            #endif
                        } else {
                            Text(verbatim: emptyText)
                                .font(font)
                                .monospacedDigit()
                                .lineLimit(lineLimit)
                                .minimumScaleFactor(minimumScaleFactor)
                                .fixedSize(horizontal: true, vertical: true)
                        }
                    } else {
                        Text(verbatim: emptyText)
                            .font(font)
                            .monospacedDigit()
                            .lineLimit(lineLimit)
                            .minimumScaleFactor(minimumScaleFactor)
                            .fixedSize(horizontal: true, vertical: true)
                    }
                }
            }
            .liveActivityAnimationsDisabled()
    }
}

// MARK: - Unified Row Layout

/// Single layout component shared by both Lock Screen and Dynamic Island Expanded.
/// Pass `compact: true` for the Lock Screen, `compact: false` for the Dynamic Island.
struct AlarmLiveActivityRow: View {
    let attributes: AlarmAttributes<FocusAlarmMetadata>
    let state: AlarmPresentationState
    var compact: Bool = true

    private var tint: Color { attributes.liveActivityTint }
    private var emoji: String { attributes.metadata?.emoji ?? "" }
    private var focusName: String { attributes.metadata?.displayName ?? "Focus" }

    private var buttonSize: CGFloat { compact ? 40 : 44 }
    private var buttonSpacing: CGFloat { compact ? 8 : 8 }
    private var iconSize: CGFloat { compact ? 18 : 20 }
    private var controlsWidth: CGFloat { compact ? 88 : 96 }
    private var countdownFontSize: CGFloat { compact ? 32 : 38 }
    private var nameFont: Font {
        compact
            ? .callout
            : .system(size: 18, weight: .semibold, design: .rounded)
    }
    private var labelClockSpacing: CGFloat { compact ? 6 : 8 }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // ── Left: Play/Pause + Stop (fixed width, leading edge) ──────────
            AlarmLiveActivityControls(
                mode: state.mode,
                alarmID: state.alarmID,
                tint: tint,
                spacing: buttonSpacing,
                buttonSize: buttonSize,
                iconSize: iconSize
            )
            .frame(width: controlsWidth, alignment: .leading)

            Spacer(minLength: 8)

            // ── Right: Grouped name and clock (trailing edge) ────────────────
            HStack(alignment: .lastTextBaseline, spacing: labelClockSpacing) {
                Text(verbatim: "\(emoji) \(focusName)")
                    .font(nameFont)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)

                AlarmCountdownText(
                    mode: state.mode,
                    emptyText: "0:00",
                    font: .system(size: countdownFontSize, weight: .regular),
                    lineLimit: 1,
                    minimumScaleFactor: 0.65
                )
            }
        }
        .foregroundStyle(tint)
        .liveActivityAnimationsDisabled()
    }

}

// MARK: - Extensions

extension AlarmAttributes where Metadata == FocusAlarmMetadata {
    var liveActivityTint: Color {
        metadata?.liveActivityColor ?? tintColor
    }
}

extension FocusAlarmMetadata {
    var liveActivityColor: Color {
        guard color.count >= 3 else { return .orange }
        return Color(red: Double(color[0]), green: Double(color[1]), blue: Double(color[2]))
    }
}

extension View {
    func liveActivityAnimationsDisabled() -> some View {
        transaction { transaction in
            transaction.animation = nil
            transaction.disablesAnimations = true
        }
    }
}
