import SwiftUI

@MainActor
@Observable
final class FocusTimerViewModel {
    let seconds: Int
    var start = false
    var end = false
    var schedulingAlarm = false
    var autoStartQueued: Bool
    var alarmErrorMessage: String?
    var alarmDisplayDate = Date.now
    var showTime = false
    var alarmCoordinator = FocusAlarmCoordinator()

    var timerActive: Bool {
        guard start, !end else { return false }
        guard let mode = alarmCoordinator.presentationState?.mode else { return false }
        if case .countdown = mode { return true }
        return false
    }

    init(seconds: Int, autoStart: Bool, isRestoring: Bool = false) {
        self.seconds = seconds
        self.autoStartQueued = autoStart
        if isRestoring {
            self.start = true
            self.showTime = true
        }
    }

    // MARK: - Timer tick

    func handleTimerTick(_ time: Date) -> Bool {
        guard start, !end else { return false }
        alarmDisplayDate = time
        return timerActive && displayedSeconds(referenceDate: time) <= 0
    }

    // MARK: - Play / Pause

    @discardableResult
    func togglePlayPause(focus: Focus, color: Color) async -> Bool {
        if !start {
            return await scheduleAndStart(focus: focus, color: color)
        } else if timerActive {
            alarmCoordinator.pauseCurrentAlarm()
        } else {
            alarmCoordinator.resumeCurrentAlarm()
        }
        showTimeIfNeeded()
        return true
    }

    // MARK: - Session lifecycle

    func complete(focus: Focus) {
        guard !end else { return }
        if showTime { showTime.toggle() }
        focus.appendSession(Session(
            name: focus.name,
            emoji: focus.emoji,
            seconds: focus.currentTime * 60,
            start: Date.now,
            color: [focus.color[0], focus.color[1], focus.color[2]]
        ))
        end = true
    }

    func close() {
        alarmCoordinator.stopOrCancelCurrentAlarm()
    }

    func stopWithoutRecording() {
        end = true
    }

    // MARK: - Display helpers

    func progress(fallbackTotal: Int) -> Double {
        guard start else { return 0 }
        return alarmCoordinator.progress(referenceDate: alarmDisplayDate, fallbackTotal: fallbackTotal)
    }

    func formattedSeconds(referenceDate: Date? = nil) -> String {
        let totalSeconds = displayedSeconds(referenceDate: referenceDate ?? alarmDisplayDate)
        let hours = totalSeconds / 3600
        let min = (totalSeconds % 3600) / 60
        let sec = (totalSeconds % 3600) % 60
        if hours > 0 {
            return "\(hours):\(String(format: "%02d", min)):\(String(format: "%02d", sec))"
        } else {
            return "\(min):\(String(format: "%02d", sec))"
        }
    }

    // MARK: - Private

    private func scheduleAndStart(focus: Focus, color: Color) async -> Bool {
        guard !schedulingAlarm else { return true }
        schedulingAlarm = true
        autoStartQueued = false

        let scheduled = await alarmCoordinator.scheduleTimer(
            for: focus,
            duration: TimeInterval(seconds),
            tintColor: color
        )
        schedulingAlarm = false

        guard scheduled else {
            alarmErrorMessage = alarmCoordinator.lastErrorDescription ?? "AlarmKit failed without returning an error."
            return false
        }
        startLocalTimer()
        return true
    }

    private func startLocalTimer() {
        if !start {
            withAnimation(.bouncy(duration: 0.45)) {
                start.toggle()
            }
        }
        showTimeIfNeeded()
    }

    private func showTimeIfNeeded() {
        if !showTime {
            withAnimation { showTime.toggle() }
        }
    }

    private func displayedSeconds(referenceDate: Date? = nil) -> Int {
        alarmCoordinator.remainingSeconds(
            referenceDate: referenceDate ?? alarmDisplayDate,
            fallback: seconds
        )
    }
}
