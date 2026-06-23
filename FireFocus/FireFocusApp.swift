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
            let configuration = ModelConfiguration(
                "FieryFocus",
                schema: Schema([Focus.self, Session.self]),
                cloudKitDatabase: .private("iCloud.FieryFocusContainer")
            )

            modelContainer = try ModelContainer(
                for: Focus.self,
                Session.self,
                configurations: configuration
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
