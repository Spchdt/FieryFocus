import ActivityKit
import AlarmKit
import AppIntents
import SwiftUI

struct AlarmFocusCard: View {
    let attributes: AlarmAttributes<FocusAlarmMetadata>
    let state: AlarmPresentationState
    let style: AlarmFocusCardStyle

    private var metadata: FocusAlarmMetadata? {
        attributes.metadata
    }

    private var tint: Color {
        metadata?.liveActivityColor ?? attributes.tintColor
    }

    var body: some View {
        switch style {
        case .lockScreen:
            lockScreenCard
        case .expandedIsland:
            AlarmExpandedIslandCard(
                metadata: metadata,
                mode: state.mode,
                alarmID: state.alarmID,
                tint: tint
            )
        }
    }

    private var lockScreenCard: some View {
        AlarmLockScreenStrip(
            metadata: metadata,
            mode: state.mode,
            alarmID: state.alarmID,
            tint: tint
        )
    }
}

struct AlarmLockScreenStrip: View {
    let metadata: FocusAlarmMetadata?
    let mode: AlarmPresentationState.Mode
    let alarmID: UUID
    let tint: Color

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            AlarmExpandedIslandControls(
                mode: mode,
                alarmID: alarmID,
                tint: tint,
                spacing: 8,
                buttonSize: 40,
                iconSize: 20
            )
            .frame(width: 88, alignment: .leading)

            AlarmLockScreenStatus(metadata: metadata, mode: mode, tint: tint)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct AlarmLockScreenStatus: View {
    let metadata: FocusAlarmMetadata?
    let mode: AlarmPresentationState.Mode
    let tint: Color

    private var emoji: String {
        metadata?.emoji ?? "🔥"
    }

    private var focusName: String {
        metadata?.displayName ?? "Focus"
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text("\(emoji) \(focusName)")
                .font(.callout)
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            AlarmLockScreenCountdown(mode: mode)
                .frame(width: 104, alignment: .trailing)
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct AlarmExpandedIslandCard: View {
    let metadata: FocusAlarmMetadata?
    let mode: AlarmPresentationState.Mode
    let alarmID: UUID
    let tint: Color

    var body: some View {
        HStack(spacing: 0) {
            AlarmExpandedIslandControls(
                mode: mode,
                alarmID: alarmID,
                tint: tint,
                spacing: 8,
                buttonSize: 40,
                iconSize: 20
            )
            .frame(width: 88, alignment: .leading)

            AlarmExpandedIslandStatus(metadata: metadata, mode: mode, tint: tint)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct AlarmExpandedIslandStatus: View {
    let metadata: FocusAlarmMetadata?
    let mode: AlarmPresentationState.Mode
    let tint: Color
    
    private var emoji: String {
        metadata?.emoji ?? "🔥"
    }
    
    private var focusName: String {
        metadata?.displayName ?? "Focus"
    }
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text("\(emoji) \(focusName)")
                .font(.callout)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .foregroundStyle(tint)
            
            AlarmExpandedIslandCountdown(mode: mode)
                .foregroundStyle(tint)
                .frame(width: 104, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .accessibilityElement(children: .combine)
    }
}

struct AlarmExpandedIslandControls: View {
    let mode: AlarmPresentationState.Mode
    let alarmID: UUID
    let tint: Color
    var spacing: CGFloat = 10
    var buttonSize: CGFloat = 40
    var iconSize: CGFloat = 20

    var body: some View {
        HStack(spacing: spacing) {
            switch mode {
            case .countdown:
                AlarmIslandCircleButton(
                    systemImage: "pause.fill",
                    intent: PauseIntent(alarmID: alarmID.uuidString),
                    foregroundStyle: tint,
                    backgroundStyle: tint.opacity(0.3),
                    size: buttonSize,
                    iconSize: iconSize
                )
            case .paused:
                AlarmIslandCircleButton(
                    systemImage: "play.fill",
                    intent: ResumeIntent(alarmID: alarmID.uuidString),
                    foregroundStyle: tint,
                    backgroundStyle: tint.opacity(0.3),
                    size: buttonSize,
                    iconSize: iconSize
                )
            default:
                EmptyView()
            }

            AlarmIslandCircleButton(
                systemImage: "xmark",
                intent: StopIntent(alarmID: alarmID.uuidString),
                foregroundStyle: .primary,
                backgroundStyle: .primary.opacity(0.2),
                size: buttonSize,
                iconSize: iconSize
            )
        }
    }
}

struct AlarmIslandCircleButton<I>: View where I: AppIntent {
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
                .frame(width: size, height: size)
                .background(backgroundStyle, in: .circle)
        }
        .buttonStyle(.plain)
    }
}

struct AlarmExpandedIslandCountdown: View {
    let mode: AlarmPresentationState.Mode

    var body: some View {
        Group {
            switch mode {
            case .countdown(let countdown):
                Text(timerInterval: Date.now ... countdown.fireDate, countsDown: true)
            case .paused(let paused):
                let remaining = Duration.seconds(paused.totalCountdownDuration - paused.previouslyElapsedDuration)
                let pattern: Duration.TimeFormatStyle.Pattern = remaining > .seconds(60 * 60) ? .hourMinuteSecond : .minuteSecond
                Text(remaining.formatted(.time(pattern: pattern)))
            default:
                Text("0:00")
            }
        }
        .font(.system(size: 35, weight: .light, design: .rounded))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.65)
    }
}

struct AlarmLockScreenCountdown: View {
    let mode: AlarmPresentationState.Mode

    var body: some View {
        Group {
            switch mode {
            case .countdown(let countdown):
                Text(timerInterval: Date.now ... countdown.fireDate, countsDown: true)
            case .paused(let paused):
                let remaining = Duration.seconds(paused.totalCountdownDuration - paused.previouslyElapsedDuration)
                let pattern: Duration.TimeFormatStyle.Pattern = remaining > .seconds(60 * 60) ? .hourMinuteSecond : .minuteSecond
                Text(remaining.formatted(.time(pattern: pattern)))
            default:
                Text("0:00")
            }
        }
        .font(.system(size: 35, weight: .light, design: .rounded))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.65)
    }
}

struct AlarmFocusProgressView: View {
    let emoji: String
    let mode: AlarmPresentationState.Mode
    let tint: Color
    let size: CGFloat
    let emojiSize: CGFloat

    var body: some View {
        ZStack {
            AlarmCircularProgressView(mode: mode, tint: tint)
                .frame(width: size, height: size)

            Text(emoji)
                .font(.system(size: emojiSize))
                .shadow(radius: 4)
                .frame(width: size * 0.64, height: size * 0.64)
                .background(.thinMaterial, in: .circle)
        }
    }
}

struct AlarmCountdownView: View {
    let mode: AlarmPresentationState.Mode
    let style: AlarmFocusCardStyle

    var body: some View {
        Group {
            switch mode {
            case .countdown(let countdown):
                Text(timerInterval: Date.now ... countdown.fireDate, countsDown: true)
            case .paused(let paused):
                let remaining = Duration.seconds(paused.totalCountdownDuration - paused.previouslyElapsedDuration)
                let pattern: Duration.TimeFormatStyle.Pattern = remaining > .seconds(60 * 60) ? .hourMinuteSecond : .minuteSecond
                Text(remaining.formatted(.time(pattern: pattern)))
            default:
                Text("Done")
            }
        }
        .font(style.countdownFont)
        .fontWeight(.bold)
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .padding(.horizontal, style.countdownHorizontalPadding)
        .padding(.vertical, style.countdownVerticalPadding)
        .background(.thinMaterial, in: .capsule)
    }
}

struct AlarmCircularProgressView: View {
    let mode: AlarmPresentationState.Mode
    let tint: Color

    var body: some View {
        Group {
            switch mode {
            case .countdown(let countdown):
                ProgressView(timerInterval: Date.now ... countdown.fireDate, countsDown: true)
            case .paused(let paused):
                let remaining = paused.totalCountdownDuration - paused.previouslyElapsedDuration
                ProgressView(value: remaining, total: paused.totalCountdownDuration)
            default:
                ProgressView(value: 0, total: 1)
            }
        }
        .progressViewStyle(.circular)
        .tint(tint)
    }
}

enum AlarmFocusCardStyle {
    case lockScreen
    case expandedIsland

    var horizontalSpacing: CGFloat {
        switch self {
        case .lockScreen: 14
        case .expandedIsland: 10
        }
    }

    var textSpacing: CGFloat {
        switch self {
        case .lockScreen: 6
        case .expandedIsland: 4
        }
    }

    var progressSize: CGFloat {
        switch self {
        case .lockScreen: 66
        case .expandedIsland: 48
        }
    }

    var emojiSize: CGFloat {
        switch self {
        case .lockScreen: 28
        case .expandedIsland: 21
        }
    }

    var titleFont: Font {
        switch self {
        case .lockScreen: .title3
        case .expandedIsland: .headline
        }
    }

    var countdownFont: Font {
        switch self {
        case .lockScreen: .caption
        case .expandedIsland: .caption2
        }
    }

    var countdownHorizontalPadding: CGFloat {
        switch self {
        case .lockScreen: 12
        case .expandedIsland: 9
        }
    }

    var countdownVerticalPadding: CGFloat {
        switch self {
        case .lockScreen: 7
        case .expandedIsland: 5
        }
    }

    var padding: CGFloat {
        switch self {
        case .lockScreen: 14
        case .expandedIsland: 0
        }
    }

    var minimumSpacer: CGFloat {
        switch self {
        case .lockScreen: 8
        case .expandedIsland: 4
        }
    }

}

extension FocusAlarmMetadata {
    var liveActivityColor: Color {
        guard color.count >= 3 else { return .orange }
        return Color(red: Double(color[0]), green: Double(color[1]), blue: Double(color[2]))
    }
}
