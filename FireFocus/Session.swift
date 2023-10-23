//
//  Session.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 23/10/2566 BE.
//

import Foundation
import SwiftData

@Model
class Session {
    let name: String
    let emoji: String
    let seconds: Int
    let start: Date
    let color: [Float]
    
    init(name: String, emoji: String, seconds: Int, start: Date, color: [Float]) {
        self.name = name
        self.emoji = emoji
        self.seconds = seconds
        self.start = start
        self.color = color
    }
}
