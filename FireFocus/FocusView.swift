//
//  HomeVIew.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import SwiftUI
import SwiftData

struct FocusView: View {
    @Environment(\.modelContext) var modelContext
    
    @Namespace private var aniColor
    @Namespace private var aniEmoji
    @Namespace private var aniName
    @Namespace private var aniContainer
    
    @Query var focuses: [Focus]
    @State var currentFocus: Focus?
    
    var body: some View {
        GeometryReader  { geo in
            NavigationStack {
                List {
                    ForEach(focuses) { focus in
                        let color = Color(red: Double(focus.color[0]), green: Double(focus.color[1]), blue: Double(focus.color[2]))
                        
                        if currentFocus == nil || currentFocus == focus {
                            Section {
                                Button {
                                    withAnimation(.bouncy(duration: 0.5)) {
                                        currentFocus = focus
                                    }
                                } label: {
                                    if currentFocus != focus {
                                        SessionButtonView(focus: focus, currentFocus: $currentFocus, aniColor: aniColor, aniEmoji: aniEmoji, aniName: aniName, aniContainer: aniContainer, color: color)
                                    } else {
                                        SessionView(focus: focus, currentFocus: $currentFocus, aniColor: aniColor, aniEmoji: aniEmoji, aniName: aniName, aniContainer: aniContainer, color: color)
                                    }
                                }
                                .foregroundStyle(.primary)
                                .roundedSection()
                            }
                            .listSectionSpacing(focuses.count == 0 || focuses[focuses.count - 1] == focus ? .default : .compact)
                        }
                    }
                    .onDelete(perform: currentFocus == nil ? deleteFocus : nil)
                    
                    if currentFocus == nil {
                        Section {
                            NavigationLink {
                                NewFocusView()
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.largeTitle)
                                    Text("Create new Focus")
                                }
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.accent)
                                .fontDesign(.rounded)
                            }
                            .frame(height: 50)
                        }
                        .roundedSection()
                    }
                }
                .navigationTitle("FieryFocus")
            }
        }
    }
    
    func deleteFocus(_ indexSet: IndexSet) {
        for index in indexSet {
            let focus = focuses[index]
            modelContext.delete(focus)
        }
    }
}

#Preview {
    FocusView()
}
