//
//  Session.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 23/10/2566 BE.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Session {
    var name: String = ""
    var emoji: String = "🔥"
    var seconds: Int = 0
    var start: Date = Date.now
    var color: [Float] = [1.0, 0.32, 0.18]
    var focus: Focus?
    
    init(name: String, emoji: String, seconds: Int, start: Date, color: [Float]) {
        self.name = name
        self.emoji = emoji
        self.seconds = seconds
        self.start = start
        self.color = color
    }
    
    func getColor() -> Color {
        return Color(red: Double(color[0]), green: Double(color[1]), blue: Double(color[2]))
    }
}
