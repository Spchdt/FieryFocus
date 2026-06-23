import AlarmKit
import Foundation

@MainActor
extension FocusAlarmCoordinator {
    func alarmPresentation(title: LocalizedStringResource) -> AlarmPresentation {
        let alertContent = AlarmPresentation.Alert(title: title, stopButton: .focusDoneButton)
        let countdownContent = AlarmPresentation.Countdown(title: title, pauseButton: .focusPauseButton)
        let pausedContent = AlarmPresentation.Paused(title: "Paused", resumeButton: .focusResumeButton)

        return AlarmPresentation(alert: alertContent, countdown: countdownContent, paused: pausedContent)
    }
}

