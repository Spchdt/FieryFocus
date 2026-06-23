//
//  ContentView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 19/10/2566 BE.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    @State private var previousTab = 1
    @State private var createNewFocus = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Focus", systemImage: "timer", value: 1) {
                FocusView()
            }
            
            Tab("Statistic", systemImage: "chart.bar.fill", value: 0) {
                StatisticView()
            }
            
            Tab("Create", systemImage: "plus", value: 2, role: .search) {
                Color.clear
            }
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            if newTab == 2 {
                selectedTab = previousTab
                createNewFocus = true
            } else {
                previousTab = newTab
            }
        }
        .sheet(isPresented: $createNewFocus) {
            NewFocusView()
        }
    }
}

#Preview {
    ContentView()
}
