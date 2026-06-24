import ActivityKit
import AlarmKit
import SwiftUI

struct AlarmCompactIslandCountdown: View {
    let state: AlarmPresentationState
    let tint: Color
    var maxWidth: CGFloat = 54

    var body: some View {
        // Reuse the fixed AlarmCountdownText so compact island also gets stable identity.
        AlarmCountdownText(
            mode: state.mode,
            emptyText: "",
            font: .caption2.weight(.semibold),
            lineLimit: 1,
            minimumScaleFactor: 0.65,
            isCompactIsland: true
        )
        .foregroundStyle(tint)
        .frame(maxWidth: maxWidth, alignment: .trailing)
        .liveActivityAnimationsDisabled()
    }
}

struct AlarmCompactIslandProgress: View {
    var metadata: FocusAlarmMetadata?
    var mode: AlarmPresentationState.Mode
    var tint: Color

    var body: some View {
        Group {
            switch mode {
            case .countdown(let countdown):
                let isPreview: Bool = {
                    #if DEBUG
                    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
                    #else
                    return false
                    #endif
                }()
                
                if isPreview {
                    let total = countdown.totalCountdownDuration
                    let elapsed = countdown.previouslyElapsedDuration + Date.now.timeIntervalSince(countdown.startDate)
                    let remaining = max(0, total - elapsed)
                    ProgressView(
                        value: remaining,
                        total: total,
                        label: { EmptyView() },
                        currentValueLabel: {
                            Text(metadata?.emoji ?? "")
                                .scaleEffect(0.8)
                        }
                    )
                } else {
                    if Date.now < countdown.fireDate {
                        ProgressView(
                            timerInterval: Date.now ... countdown.fireDate,
                            countsDown: true,
                            label: { EmptyView() },
                            currentValueLabel: {
                                Text(metadata?.emoji ?? "")
                                    .scaleEffect(0.8)
                            }
                        )
                    } else {
                        ProgressView(
                            value: 0,
                            total: 1,
                            label: { EmptyView() },
                            currentValueLabel: {
                                Text(metadata?.emoji ?? "")
                                    .scaleEffect(0.8)
                            }
                        )
                    }
                }
            case .paused(let pausedState):
                let remaining = pausedState.totalCountdownDuration - pausedState.previouslyElapsedDuration
                ProgressView(
                    value: remaining,
                    total: pausedState.totalCountdownDuration,
                    label: { EmptyView() },
                    currentValueLabel: {
                        Image(systemName: "pause.fill")
                            .scaleEffect(0.8)
                    }
                )
            default:
                EmptyView()
            }
        }
        .progressViewStyle(.circular)
        .foregroundStyle(tint)
        .tint(tint)
        .contentTransition(.identity)
    }
}
