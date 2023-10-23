//
//  MeditasteApp.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 19/10/2566 BE.
//

import SwiftUI
import SwiftData

@main
struct FireFocusApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Focus.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
