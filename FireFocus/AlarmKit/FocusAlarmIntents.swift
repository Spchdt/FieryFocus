//
//  FocusAlarmIntents.swift
//  FieryFocus
//

import AlarmKit
import AppIntents
import Foundation
import SwiftUI

struct PauseIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause"
    static var description = IntentDescription("Pause a focus countdown")
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else { return .result() }
        try AlarmManager.shared.pause(id: id)
        return .result()
    }
}

struct ResumeIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Resume"
    static var description = IntentDescription("Resume a focus countdown")
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else { return .result() }
        try AlarmManager.shared.resume(id: id)
        return .result()
    }
}

struct StopIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop"
    static var description = IntentDescription("Stop a focus alert")
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else { return .result() }
        do {
            try AlarmManager.shared.stop(id: id)
        } catch {
            try AlarmManager.shared.cancel(id: id)
        }
        return .result()
    }
}

struct OpenFocusAppIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Open FieryFocus"
    static var description = IntentDescription("Open FieryFocus")
    static var openAppWhenRun = true
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: String) {
        self.alarmID = alarmID
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else { return .result() }
        try? AlarmManager.shared.stop(id: id)
        return .result()
    }
}

extension AlarmButton {
    static var focusPauseButton: Self {
        AlarmButton(text: "Pause", textColor: .black, systemImageName: "pause.fill")
    }
    
    static var focusResumeButton: Self {
        AlarmButton(text: "Start", textColor: .black, systemImageName: "play.fill")
    }
    
    static var focusDoneButton: Self {
        AlarmButton(text: "Stop", textColor: .white, systemImageName: "stop.circle")
    }
}
