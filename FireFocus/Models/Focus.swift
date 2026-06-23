//
//  Focus.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import SwiftUI
import SwiftData

@Model
class Focus {
    var name: String = ""
    var quote: String = ""
    var time: [Int] = [25]
    var currentTime: Int = 25
    var sortOrder: Int = 0
    
    var emoji: String = "🔥"
    var color: [Float] = [1.0, 0.32, 0.18]
    
    @Relationship(deleteRule: .cascade, inverse: \Session.focus) var sessions: [Session]? = []
    
    init(name: String, quote: String, time: [Int], emoji: String, color: [Float]) {
        self.name = name
        self.quote = quote
        self.time = time
        self.emoji = emoji
        self.color = color
        self.currentTime = time[0]
        self.sortOrder = 0
    }
    
    func getColor() -> Color {
        return Color(red: Double(color[0]), green: Double(color[1]), blue: Double(color[2]))
    }

    var savedSessions: [Session] {
        sessions ?? []
    }

    func appendSession(_ session: Session) {
        session.focus = self

        if sessions == nil {
            sessions = []
        }

        sessions?.append(session)
    }
}
