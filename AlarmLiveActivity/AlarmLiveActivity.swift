//
//  AlarmLiveActivity.swift
//  FieryFocus
//

import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

struct AlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<FocusAlarmMetadata>.self) { context in
            AlarmLockScreenView(
                attributes: context.attributes,
                state: context.state
            )
            .containerBackground(for: .widget) {
                Color.black
            }
            .activityBackgroundTint(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    AlarmExpandedIslandView(
                        attributes: context.attributes,
                        state: context.state
                    )
                }
            } compactLeading: {
                AlarmCompactIslandProgress(
                    metadata: context.attributes.metadata,
                    mode: context.state.mode,
                    tint: context.attributes.liveActivityTint
                )
            } compactTrailing: {
                AlarmCompactIslandCountdown(state: context.state, tint: context.attributes.liveActivityTint)
            } minimal: {
                AlarmCompactIslandProgress(
                    metadata: context.attributes.metadata,
                    mode: context.state.mode,
                    tint: context.attributes.liveActivityTint
                )
            }
            .keylineTint(context.attributes.liveActivityTint)
        }
    }
}

// MARK: - Previews

#Preview("Widget - Lock Screen", as: .content, using: AlarmLiveActivityPreviewData.attributes) {
    AlarmLiveActivity()
} contentStates: {
    AlarmLiveActivityPreviewData.countdown
    AlarmLiveActivityPreviewData.paused
}

#Preview("Widget - Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: AlarmLiveActivityPreviewData.attributes) {
    AlarmLiveActivity()
} contentStates: {
    AlarmLiveActivityPreviewData.countdown
    AlarmLiveActivityPreviewData.paused
}

#Preview("Widget - Dynamic Island Compact", as: .dynamicIsland(.compact), using: AlarmLiveActivityPreviewData.attributes) {
    AlarmLiveActivity()
} contentStates: {
    AlarmLiveActivityPreviewData.countdown
    AlarmLiveActivityPreviewData.paused
}

#Preview("Widget - Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: AlarmLiveActivityPreviewData.attributes) {
    AlarmLiveActivity()
} contentStates: {
    AlarmLiveActivityPreviewData.countdown
    AlarmLiveActivityPreviewData.paused
}

// MARK: - View Previews

#Preview("Lock Screen - Countdown") {
    AlarmLockScreenView(
        attributes: AlarmLiveActivityPreviewData.attributes,
        state: AlarmLiveActivityPreviewData.countdown
    )
    .padding()
    .background(.black)
}

#Preview("Lock Screen - Paused") {
    AlarmLockScreenView(
        attributes: AlarmLiveActivityPreviewData.attributes,
        state: AlarmLiveActivityPreviewData.paused
    )
    .padding()
    .background(.black)
}

#Preview("Lock Screen - Long Name") {
    AlarmLockScreenView(
        attributes: AlarmLiveActivityPreviewData.longNameAttributes,
        state: AlarmLiveActivityPreviewData.countdown
    )
    .padding()
    .background(.black)
}

#Preview("Expanded Island - Countdown") {
    AlarmExpandedIslandView(
        attributes: AlarmLiveActivityPreviewData.attributes,
        state: AlarmLiveActivityPreviewData.countdown
    )
    .padding()
    .frame(width: 390)
    .background(.black, in: .capsule)
}

#Preview("Expanded Island - Paused") {
    AlarmExpandedIslandView(
        attributes: AlarmLiveActivityPreviewData.attributes,
        state: AlarmLiveActivityPreviewData.paused
    )
    .padding()
    .frame(width: 390)
    .background(.black, in: .capsule)
}

#Preview("Expanded Island - Long Name") {
    AlarmExpandedIslandView(
        attributes: AlarmLiveActivityPreviewData.longNameAttributes,
        state: AlarmLiveActivityPreviewData.countdown
    )
    .padding()
    .frame(width: 390)
    .background(.black, in: .capsule)
}

#Preview("Compact Island - Countdown") {
    HStack(spacing: 8) {
        AlarmCompactIslandCountdown(
            state: AlarmLiveActivityPreviewData.countdown,
            tint: AlarmLiveActivityPreviewData.attributes.liveActivityTint
        )

        AlarmCompactIslandProgress(
            metadata: AlarmLiveActivityPreviewData.attributes.metadata,
            mode: AlarmLiveActivityPreviewData.countdown.mode,
            tint: AlarmLiveActivityPreviewData.attributes.liveActivityTint
        )
    }
    .padding()
    .background(.black, in: .capsule)
}

#Preview("Compact Island - Paused") {
    HStack(spacing: 8) {
        AlarmCompactIslandCountdown(
            state: AlarmLiveActivityPreviewData.paused,
            tint: AlarmLiveActivityPreviewData.attributes.liveActivityTint
        )

        AlarmCompactIslandProgress(
            metadata: AlarmLiveActivityPreviewData.attributes.metadata,
            mode: AlarmLiveActivityPreviewData.paused.mode,
            tint: AlarmLiveActivityPreviewData.attributes.liveActivityTint
        )
    }
    .padding()
    .background(.black, in: .capsule)
}

// MARK: - Mock Data

enum AlarmLiveActivityPreviewData {
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

    static let longNameAttributes = AlarmAttributes(
        presentation: AlarmPresentation(
            alert: .init(title: "Really Long Deep Work Session", stopButton: .focusDoneButton),
            countdown: .init(title: "Really Long Deep Work Session", pauseButton: .focusPauseButton),
            paused: .init(title: "Paused", resumeButton: .focusResumeButton)
        ),
        metadata: FocusAlarmMetadata(
            name: "Really Long Deep Work Session",
            emoji: "🧠",
            color: [0.62, 0.44, 1.0]
        ),
        tintColor: .purple
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

    static var almostDone: AlarmPresentationState {
        AlarmPresentationState(
            alarmID: alarmID,
            mode: .countdown(.init(
                totalCountdownDuration: duration,
                previouslyElapsedDuration: duration - 37,
                startDate: .now.addingTimeInterval(-(duration - 37)),
                fireDate: .now.addingTimeInterval(37)
            ))
        )
    }
}
