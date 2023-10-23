//
//  SessionButtonView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 23/10/2566 BE.
//

import SwiftUI

struct SessionButtonView: View {
    @Bindable var focus: Focus
    @Binding var currentFocus: Focus?
    
    let aniColor: Namespace.ID
    let aniEmoji: Namespace.ID
    let aniName: Namespace.ID
    let aniContainer: Namespace.ID
    
    let color: Color
    @State private var timeAlert = false
    
    init(focus: Focus, currentFocus: Binding<Focus?>, aniColor: Namespace.ID, aniEmoji: Namespace.ID, aniName: Namespace.ID, aniContainer: Namespace.ID, color: Color) {
        self.focus = focus
        self._currentFocus = currentFocus
        self.aniColor = aniColor
        self.aniEmoji = aniEmoji
        self.aniName = aniName
        self.aniContainer = aniContainer
        self.color = color
    }
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .foregroundStyle(color)
                        .matchedGeometryEffect(id: focus.id, in: aniColor)
                        .frame(width: 60, height: 60)
                    Text(focus.emoji)
                        .font(.system(size: 30))
                        .matchedGeometryEffect(id: focus.id, in: aniEmoji)
                }
                
                
                .frame(width: 60, height: 60)
                .padding(.trailing, 5)
                
                Text(focus.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .matchedGeometryEffect(id: focus.id, in: aniName)
                
                Spacer()
                Menu {
                    ForEach (focus.time, id:\.self) { time in
                        Button("\(time) min") {
                            focus.currentTime = time
                        }
                    }
                    Button {
                        timeAlert.toggle()
                    } label: {
                        Label("Edit time", systemImage: "square.and.pencil")
                    }

                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(color.opacity(0.5))
                            .frame(width: 90, height: 40)
                        Group {
                            Text("\(focus.currentTime) min ")
                            + Text(Image(systemName: "chevron.down"))
                                .font(.caption)
                        }
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }
                }
            }
        }
        .sheet(isPresented: $timeAlert, content: {
            EditTimeView(focus: focus)
        })
        .matchedGeometryEffect(id: focus.id, in: aniContainer)
    }
}
