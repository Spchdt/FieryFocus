//
//  ContentView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 19/10/2566 BE.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FocusView()
            .tag(1)
            .tabItem { Label("Focus", systemImage: "clock.arrow.circlepath") }
            
            HistoryView()
            .tag(0)
            .tabItem { Label("History", systemImage: "calendar") }
        }
    }
}

#Preview {
    ContentView()
}
