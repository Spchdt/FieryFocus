//
//  FocusAlarmMetadata.swift
//  FieryFocus
//

import AlarmKit
import Foundation

struct FocusAlarmMetadata: AlarmMetadata {
    let name: String
    let emoji: String
    let color: [Float]
    let createdAt: Date
    
    init(name: String, emoji: String, color: [Float]) {
        self.name = name
        self.emoji = emoji
        self.color = color
        self.createdAt = Date.now
    }
    
    var displayName: String {
        name.isEmpty ? "Focus" : name
    }
}
