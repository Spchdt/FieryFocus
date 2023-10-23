//
//  Focus.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import Foundation
import SwiftData

@Model
class Focus {
    var name: String
    var quote: String
    var time: [Int]
    var currentTime: Int
    
    var emoji: String
    var color: [Float]
    
    @Relationship(deleteRule: .cascade) var sessions = [Session]()
    
    init(name: String, quote: String, time: [Int], emoji: String, color: [Float]) {
        self.name = name
        self.quote = quote
        self.time = time
        self.emoji = emoji
        self.color = color
        self.currentTime = time[0]
    }
}
