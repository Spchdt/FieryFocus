import SwiftUI

@MainActor
@Observable
final class FocusTimerSession {
    let seconds: Int
    var start = false
    var end = false
    var timerActive = false
    var schedulingAlarm = false
    var autoStartQueued: Bool
    var alarmErrorMessage: String?
    var alarmDisplayDate = Date.now
    var showTime = false
    var alarmCoordinator = FocusAlarmCoordinator()

    init(seconds: Int, autoStart: Bool) {
        self.seconds = seconds
        self.autoStartQueued = autoStart
    }

    func consumeAutoStartRequest() -> Bool {
        guard autoStartQueued, !start, !end else { return false }
        autoStartQueued = false
        return true
    }

    func handleTimerTick(_ time: Date) -> Bool {
        guard start, !end else { return false }
        alarmDisplayDate = time
        return timerActive && displayedSeconds(referenceDate: time) <= 0
    }

    func playPauseTimer(focus: Focus, color: Color) async {
        if !start {
            await scheduleAndStart(focus: focus, color: color)
            return
        } else if timerActive {
            alarmCoordinator.pauseCurrentAlarm()
        } else {
            alarmCoordinator.resumeCurrentAlarm()
        }

        showTimeIfNeeded()
        timerActive.toggle()
    }

    func complete(focus: Focus) {
        guard !end else { return }

        if showTime {
            showTime.toggle()
        }

        focus.appendSession(Session(
            name: focus.name,
            emoji: focus.emoji,
            seconds: focus.currentTime * 60,
            start: Date.now,
            color: [focus.color[0], focus.color[1], focus.color[2]]
        ))
        timerActive = false
        end = true
    }

    func close() {
        alarmCoordinator.stopOrCancelCurrentAlarm()
    }

    func stopWithoutRecording() {
        timerActive = false
        end = true
    }

    func progress(fallbackTotal: Int) -> Double {
        guard start else { return 0 }
        return alarmCoordinator.progress(referenceDate: alarmDisplayDate, fallbackTotal: fallbackTotal)
    }

    func formattedSeconds(referenceDate: Date? = nil) -> String {
        let seconds = displayedSeconds(referenceDate: referenceDate ?? alarmDisplayDate)
        let min = (seconds % 3600) / 60
        let sec = (seconds % 3600) % 60
        return "\(min):\(String(format: "%02d", sec))"
    }

    private func scheduleAndStart(focus: Focus, color: Color) async {
        guard !schedulingAlarm else { return }
        schedulingAlarm = true

        let scheduled = await alarmCoordinator.scheduleTimer(
            for: focus,
            duration: TimeInterval(seconds),
            tintColor: color
        )
        schedulingAlarm = false

        guard scheduled else {
            alarmErrorMessage = alarmCoordinator.lastErrorDescription ?? "AlarmKit failed without returning an error."
            return
        }

        startLocalTimer()
    }

    private func startLocalTimer() {
        if !start {
            withAnimation(.bouncy(duration: 0.45)) {
                start.toggle()
            }
        }

        showTimeIfNeeded()
        timerActive.toggle()
    }

    private func showTimeIfNeeded() {
        if !showTime {
            withAnimation {
                showTime.toggle()
            }
        }
    }

    private func displayedSeconds(referenceDate: Date? = nil) -> Int {
        alarmCoordinator.remainingSeconds(referenceDate: referenceDate ?? alarmDisplayDate, fallback: seconds)
    }
}
