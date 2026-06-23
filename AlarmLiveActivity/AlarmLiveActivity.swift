//
//  AlarmLiveActivity.swift
//  FieryFocus
//

import ActivityKit
import AlarmKit
import AppIntents
import SwiftUI
import WidgetKit

struct AlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<FocusAlarmMetadata>.self) { context in
            AlarmFocusCard(
                attributes: context.attributes,
                state: context.state,
                style: .lockScreen
            )
            .containerBackground(for: .widget) {
                Color.black
            }
            .activityBackgroundTint(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    AlarmFocusCard(
                        attributes: context.attributes,
                        state: context.state,
                        style: .expandedIsland
                    )
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }
            } compactLeading: {
                countdown(state: context.state, maxWidth: 54)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(context.attributes.tintColor)
            } compactTrailing: {
                AlarmProgressView(metadata: context.attributes.metadata,
                                  mode: context.state.mode,
                                  tint: context.attributes.tintColor)
            } minimal: {
                AlarmProgressView(metadata: context.attributes.metadata,
                                  mode: context.state.mode,
                                  tint: context.attributes.tintColor)
            }
            .keylineTint(context.attributes.tintColor)
        }
    }
    
    func countdown(state: AlarmPresentationState, maxWidth: CGFloat = .infinity) -> some View {
        Group {
            switch state.mode {
            case .countdown(let countdown):
                Text(timerInterval: Date.now ... countdown.fireDate, countsDown: true)
            case .paused(let state):
                let remaining = Duration.seconds(state.totalCountdownDuration - state.previouslyElapsedDuration)
                let pattern: Duration.TimeFormatStyle.Pattern = remaining > .seconds(60 * 60) ? .hourMinuteSecond : .minuteSecond
                Text(remaining.formatted(.time(pattern: pattern)))
            default:
                EmptyView()
            }
        }
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .frame(maxWidth: maxWidth, alignment: .leading)
    }
}

struct AlarmBackgroundGradient: View {
    let tint: Color

    var body: some View {
        LinearGradient(
            colors: [
                tint.opacity(0.55),
                tint.opacity(0.18),
                .clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct AlarmProgressView: View {
    var metadata: FocusAlarmMetadata?
    var mode: AlarmPresentationState.Mode
    var tint: Color
    
    var body: some View {
        Group {
            switch mode {
            case .countdown(let countdown):
                ProgressView(
                    timerInterval: Date.now ... countdown.fireDate,
                    countsDown: true,
                    label: { EmptyView() },
                    currentValueLabel: {
                        Text(metadata?.emoji ?? "")
                            .scaleEffect(0.8)
                    })
            case .paused(let pausedState):
                let remaining = pausedState.totalCountdownDuration - pausedState.previouslyElapsedDuration
                ProgressView(value: remaining,
                             total: pausedState.totalCountdownDuration,
                             label: { EmptyView() },
                             currentValueLabel: {
                    Image(systemName: "pause.fill")
                        .scaleEffect(0.8)
                })
            default:
                EmptyView()
            }
        }
        .progressViewStyle(.circular)
        .foregroundStyle(tint)
        .tint(tint)
    }
}

struct AlarmControls: View {
    var state: AlarmPresentationState
    
    var body: some View {
        VStack(spacing: 5) {
            switch state.mode {
            case .countdown:
                ButtonView(
                    config: .focusPauseButton,
                    intent: PauseIntent(alarmID: state.alarmID.uuidString),
                    tint: .white,
                    foregroundStyle: .black
                )
            case .paused:
                ButtonView(
                    config: .focusResumeButton,
                    intent: ResumeIntent(alarmID: state.alarmID.uuidString),
                    tint: .white,
                    foregroundStyle: .black
                )
            default:
                EmptyView()
            }
            
            ButtonView(
                config: .focusDoneButton,
                intent: StopIntent(alarmID: state.alarmID.uuidString),
                tint: .red,
                foregroundStyle: .white
            )
        }
    }
}

struct ButtonView<I>: View where I: AppIntent {
    var config: AlarmButton
    var intent: I
    var tint: Color
    var foregroundStyle: Color
    
    var body: some View {
        Button(intent: intent) {
            Label(config.text, systemImage: config.systemImageName)
                .lineLimit(1)
                .font(.caption.weight(.semibold))
                .foregroundStyle(foregroundStyle)
        }
        .tint(tint)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.small)
        .frame(width: 78, height: 28)
    }
}

#Preview("Lock Screen", as: .content, using: AlarmLiveActivityPreview.attributes) {
    AlarmLiveActivity()
} contentStates: {
    AlarmLiveActivityPreview.countdown
    AlarmLiveActivityPreview.paused
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: AlarmLiveActivityPreview.attributes) {
    AlarmLiveActivity()
} contentStates: {
    AlarmLiveActivityPreview.countdown
    AlarmLiveActivityPreview.paused
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: AlarmLiveActivityPreview.attributes) {
    AlarmLiveActivity()
} contentStates: {
    AlarmLiveActivityPreview.countdown
    AlarmLiveActivityPreview.paused
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: AlarmLiveActivityPreview.attributes) {
    AlarmLiveActivity()
} contentStates: {
    AlarmLiveActivityPreview.countdown
    AlarmLiveActivityPreview.paused
}

private enum AlarmLiveActivityPreview {
    static let alarmID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    static let duration: TimeInterval = 25 * 60

    static let attributes = AlarmAttributes(
        presentation: AlarmPresentation(
            alert: .init(title: "Deep Work", stopButton: .focusDoneButton),
            countdown: .init(title: "Deep Work", pauseButton: .focusPauseButton),
            paused: .init(title: "Paused", resumeButton: .focusResumeButton)
        ),
        metadata: FocusAlarmMetadata(
            name: "Deep Work",
            emoji: "🔥",
            color: [1.0, 0.32, 0.18]
        ),
        tintColor: .orange
    )

    static var countdown: AlarmPresentationState {
        AlarmPresentationState(
            alarmID: alarmID,
            mode: .countdown(.init(
                totalCountdownDuration: duration,
                previouslyElapsedDuration: 8 * 60,
                startDate: .now.addingTimeInterval(-8 * 60),
                fireDate: .now.addingTimeInterval(17 * 60)
            ))
        )
    }

    static var paused: AlarmPresentationState {
        AlarmPresentationState(
            alarmID: alarmID,
            mode: .paused(.init(
                totalCountdownDuration: duration,
                previouslyElapsedDuration: 12 * 60
            ))
        )
    }
}
