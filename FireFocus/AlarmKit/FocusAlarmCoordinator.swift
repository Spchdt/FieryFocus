//
//  FocusAlarmCoordinator.swift
//  FieryFocus
//

import ActivityKit
import AlarmKit
import Foundation
import SwiftUI

@MainActor
@Observable
final class FocusAlarmCoordinator {
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<FocusAlarmMetadata>
    typealias FocusAlarmActivity = Activity<AlarmAttributes<FocusAlarmMetadata>>
    
    static var activeAlarmFocusName: String? {
        FocusAlarmActivity.activities.first?.attributes.metadata?.name
    }
    
    var currentAlarm: Alarm?
    var presentationState: AlarmPresentationState?
    var lastErrorDescription: String?
    var externalCompletionCount = 0
    var externalStopCount = 0
    
    private var activeAlarmID: UUID? {
        currentAlarm?.id ?? FocusAlarmActivity.activities.first?.content.state.alarmID
    }
    
    @ObservationIgnored let alarmManager = AlarmManager.shared
    @ObservationIgnored var alarmUpdatesTask: Task<Void, Never>?
    @ObservationIgnored var activityUpdatesTask: Task<Void, Never>?
    @ObservationIgnored var contentUpdatesTask: Task<Void, Never>?
    @ObservationIgnored var activityStateUpdatesTask: Task<Void, Never>?
    
    init() {
        observeAlarms()
        observeActivities()
        restoreActiveActivityIfNeeded()
    }
    
    deinit {
        alarmUpdatesTask?.cancel()
        activityUpdatesTask?.cancel()
        contentUpdatesTask?.cancel()
        activityStateUpdatesTask?.cancel()
    }
    
    func cleanupStaleActivities() {
        Task {
            for activity in FocusAlarmActivity.activities {
                if activity.content.state.alarmID != currentAlarm?.id {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }
    
    @discardableResult
    func scheduleTimer(for focus: Focus, duration: TimeInterval, tintColor: Color) async -> Bool {
        guard duration > 0 else {
            lastErrorDescription = "AlarmKit timer duration must be greater than zero."
            print("AlarmKit schedule skipped: \(lastErrorDescription ?? "unknown error")")
            return false
        }
        
        stopOrCancelCurrentAlarm()
        cleanupStaleActivities()
        activityStateUpdatesTask?.cancel()
        activityStateUpdatesTask = nil
        
        let id = UUID()
        let title = LocalizedStringResource(stringLiteral: focus.name.isEmpty ? "Focus" : focus.name)
        let attributes = AlarmAttributes(
            presentation: alarmPresentation(title: title),
            metadata: FocusAlarmMetadata(name: focus.name, emoji: focus.emoji, color: focus.color),
            tintColor: tintColor
        )
        let configuration = AlarmConfiguration.timer(
            duration: duration,
            attributes: attributes,
            stopIntent: StopIntent(alarmID: id.uuidString)
        )
        
        do {
            print("AlarmKit schedule requested: id=\(id.uuidString), focus=\(focus.name), duration=\(duration)")
            
            guard try await requestAuthorization() else {
                lastErrorDescription = "AlarmKit authorization was denied."
                print("AlarmKit schedule failed: \(lastErrorDescription ?? "unknown error")")
                return false
            }
            
            currentAlarm = try await alarmManager.schedule(id: id, configuration: configuration)
            presentationState = AlarmPresentationState(
                alarmID: id,
                mode: .countdown(.init(
                    totalCountdownDuration: duration,
                    previouslyElapsedDuration: 0,
                    startDate: Date.now,
                    fireDate: Date.now.addingTimeInterval(duration)
                ))
            )
            await attachToActivity(alarmID: id)
            lastErrorDescription = nil
            print("AlarmKit schedule succeeded: id=\(id.uuidString)")
            return true
        } catch {
            lastErrorDescription = error.localizedDescription
            print("AlarmKit schedule failed: \(error)")
            return false
        }
    }
    
    func pauseCurrentAlarm() {
        guard let alarmID = activeAlarmID else { return }
        
        do {
            try alarmManager.pause(id: alarmID)
            if let presentationState, case .countdown(let countdown) = presentationState.mode {
                self.presentationState = AlarmPresentationState(
                    alarmID: alarmID,
                    mode: .paused(.init(
                        totalCountdownDuration: countdown.totalCountdownDuration,
                        previouslyElapsedDuration: min(
                            countdown.totalCountdownDuration,
                            max(0, countdown.totalCountdownDuration - countdown.fireDate.timeIntervalSince(Date.now))
                        )
                    ))
                )
            }
            lastErrorDescription = nil
        } catch {
            lastErrorDescription = error.localizedDescription
        }
    }
    
    func resumeCurrentAlarm() {
        guard let alarmID = activeAlarmID else { return }
        
        do {
            try alarmManager.resume(id: alarmID)
            if let presentationState, case .paused(let paused) = presentationState.mode {
                let remaining = max(0, paused.totalCountdownDuration - paused.previouslyElapsedDuration)
                self.presentationState = AlarmPresentationState(
                    alarmID: alarmID,
                    mode: .countdown(.init(
                        totalCountdownDuration: paused.totalCountdownDuration,
                        previouslyElapsedDuration: paused.previouslyElapsedDuration,
                        startDate: Date.now,
                        fireDate: Date.now.addingTimeInterval(remaining)
                    ))
                )
            }
            lastErrorDescription = nil
        } catch {
            lastErrorDescription = error.localizedDescription
        }
    }
    
    func stopOrCancelCurrentAlarm() {
        guard let alarmID = activeAlarmID else { return }
        
        do {
            let isAlerting: Bool
            if let alarm = currentAlarm {
                isAlerting = alarm.state == .alerting
            } else if let mode = presentationState?.mode {
                if case .alert = mode {
                    isAlerting = true
                } else {
                    isAlerting = false
                }
            } else {
                isAlerting = false
            }
            
            if isAlerting {
                try alarmManager.stop(id: alarmID)
            } else {
                try alarmManager.cancel(id: alarmID)
            }
            currentAlarm = nil
            presentationState = nil
            contentUpdatesTask?.cancel()
            contentUpdatesTask = nil
            activityStateUpdatesTask?.cancel()
            activityStateUpdatesTask = nil
            lastErrorDescription = nil
        } catch {
            do {
                try alarmManager.cancel(id: alarmID)
                currentAlarm = nil
                presentationState = nil
                contentUpdatesTask?.cancel()
                contentUpdatesTask = nil
                activityStateUpdatesTask?.cancel()
                activityStateUpdatesTask = nil
                lastErrorDescription = nil
            } catch {
                lastErrorDescription = error.localizedDescription
            }
        }
        
        Task {
            for activity in FocusAlarmActivity.activities {
                if activity.content.state.alarmID == alarmID {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }
    
    func remainingSeconds(referenceDate: Date = Date.now, fallback: Int) -> Int {
        guard let presentationState else { return fallback }
        
        switch presentationState.mode {
        case .countdown(let countdown):
            return max(0, Int(ceil(countdown.fireDate.timeIntervalSince(referenceDate))))
        case .paused(let paused):
            return max(0, Int(ceil(paused.totalCountdownDuration - paused.previouslyElapsedDuration)))
        case .alert:
            return 0
        @unknown default:
            return fallback
        }
    }
    
    func progress(referenceDate: Date = Date.now, fallbackTotal: Int) -> Double {
        guard let presentationState else { return 0 }
        
        let total: TimeInterval
        let remaining: TimeInterval
        
        switch presentationState.mode {
        case .countdown(let countdown):
            total = countdown.totalCountdownDuration
            remaining = max(0, countdown.fireDate.timeIntervalSince(referenceDate))
        case .paused(let paused):
            total = paused.totalCountdownDuration
            remaining = max(0, paused.totalCountdownDuration - paused.previouslyElapsedDuration)
        case .alert:
            total = TimeInterval(fallbackTotal)
            remaining = 0
        @unknown default:
            return 0
        }
        
        guard total > 0 else { return 0 }
        return min(max((total - remaining) / total, 0), 1)
    }
    
}
