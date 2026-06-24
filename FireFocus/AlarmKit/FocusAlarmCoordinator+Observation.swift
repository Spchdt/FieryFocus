import ActivityKit
import AlarmKit
import Foundation

@MainActor
extension FocusAlarmCoordinator {
    func observeAlarms() {
        alarmUpdatesTask = Task { [weak self] in
            guard let self else { return }

            for await alarms in alarmManager.alarmUpdates {
                updateCurrentAlarm(with: alarms)
            }
        }
    }

    func observeActivities() {
        activityUpdatesTask = Task { [weak self] in
            guard let self else { return }

            for await activity in FocusAlarmActivity.activityUpdates {
                await attachToActivity(activity)
            }
        }
    }

    func attachToActivity(alarmID: Alarm.ID) async {
        for _ in 0..<10 {
            if let activity = FocusAlarmActivity.activities.first(where: { $0.content.state.alarmID == alarmID }) {
                await attachToActivity(activity)
                return
            }

            try? await Task.sleep(for: .milliseconds(100))
        }
    }

    func restoreActiveActivityIfNeeded() {
        if let activity = FocusAlarmActivity.activities.first {
            presentationState = activity.content.state
            
            contentUpdatesTask?.cancel()
            contentUpdatesTask = Task { [weak self, activity] in
                for await content in activity.contentUpdates {
                    await MainActor.run {
                        let activeID = self?.currentAlarm?.id ?? FocusAlarmActivity.activities.first?.content.state.alarmID
                        guard content.state.alarmID == activeID else { return }
                        self?.presentationState = content.state
                    }
                }
            }

            activityStateUpdatesTask?.cancel()
            activityStateUpdatesTask = Task { [weak self, activity] in
                for await activityState in activity.activityStateUpdates {
                    await MainActor.run {
                        let activeID = self?.currentAlarm?.id ?? FocusAlarmActivity.activities.first?.content.state.alarmID
                        guard activity.content.state.alarmID == activeID else { return }

                        switch activityState {
                        case .ended, .dismissed:
                            self?.markExternallyEnded()
                        default:
                            break
                        }
                    }
                }
            }
        }
    }

    func attachToActivity(_ activity: FocusAlarmActivity) async {
        let activeID = currentAlarm?.id ?? FocusAlarmActivity.activities.first?.content.state.alarmID
        guard activity.content.state.alarmID == activeID else { return }

        presentationState = activity.content.state
        contentUpdatesTask?.cancel()
        contentUpdatesTask = Task { [weak self, activity] in
            for await content in activity.contentUpdates {
                await MainActor.run {
                    let currentActiveID = self?.currentAlarm?.id ?? FocusAlarmActivity.activities.first?.content.state.alarmID
                    guard content.state.alarmID == currentActiveID else { return }
                    self?.presentationState = content.state
                }
            }
        }

        activityStateUpdatesTask?.cancel()
        activityStateUpdatesTask = Task { [weak self, activity] in
            for await activityState in activity.activityStateUpdates {
                await MainActor.run {
                    let currentActiveID = self?.currentAlarm?.id ?? FocusAlarmActivity.activities.first?.content.state.alarmID
                    guard activity.content.state.alarmID == currentActiveID else { return }

                    switch activityState {
                    case .ended, .dismissed:
                        self?.markExternallyEnded()
                    default:
                        break
                    }
                }
            }
        }
    }

    func updateCurrentAlarm(with alarms: [Alarm]) {
        let activeID = currentAlarm?.id ?? FocusAlarmActivity.activities.first?.content.state.alarmID

        if let alarmID = activeID {
            if let updatedAlarm = alarms.first(where: { $0.id == alarmID }) {
                currentAlarm = updatedAlarm
            }
        } else {
            if let firstAlarm = alarms.first {
                currentAlarm = firstAlarm
                Task {
                    await attachToActivity(alarmID: firstAlarm.id)
                }
            }
        }
    }

    func markExternallyEnded() {
        if shouldTreatCurrentActivityAsCompleted {
            externalCompletionCount += 1
        } else {
            externalStopCount += 1
        }

        currentAlarm = nil
        presentationState = nil
        contentUpdatesTask?.cancel()
        contentUpdatesTask = nil
        activityStateUpdatesTask?.cancel()
        activityStateUpdatesTask = nil
    }

    private var shouldTreatCurrentActivityAsCompleted: Bool {
        guard let presentationState else { return false }

        switch presentationState.mode {
        case .alert:
            return true
        case .countdown(let countdown):
            return countdown.fireDate <= Date.now
        default:
            return false
        }
    }
}
