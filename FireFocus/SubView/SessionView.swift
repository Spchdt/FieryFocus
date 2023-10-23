//
//  SessionView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 23/10/2566 BE.
//

import SwiftUI

struct SessionView: View {
    @Bindable var focus: Focus
    @Binding var currentFocus: Focus?
    
    let aniColor: Namespace.ID
    let aniEmoji: Namespace.ID
    let aniName: Namespace.ID
    let aniContainer: Namespace.ID
    @Namespace private var aniXMark
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let color: Color
    @State private var seconds : Int
    @State private var start = false
    @State private var end = false
    @State private var timerActive = false
    
    @State private var showTime = false
    
    init(focus: Focus, currentFocus: Binding<Focus?>, aniColor: Namespace.ID, aniEmoji: Namespace.ID, aniName: Namespace.ID, aniContainer: Namespace.ID, color: Color) {
        self.focus = focus
        self._currentFocus = currentFocus
        self.aniColor = aniColor
        self.aniEmoji = aniEmoji
        self.aniName = aniName
        self.aniContainer = aniContainer
        self.color = color
        self._seconds = State(wrappedValue: focus.currentTime * 60)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation(.bouncy(duration: 0.5)) {
                        currentFocus = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(3)
                }
                .tint(.secondary.opacity(0.3))
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .matchedGeometryEffect(id: focus.id, in: aniXMark)
            }
            .opacity(start == end ? 1 : 0)
            .padding(.vertical, 5)
            .padding(.top, 10)
            
            HStack {
                Spacer()
                VStack {
                    ZStack {
                        CircularProgressView(progress: calProgress(), color: color)
                            .frame(width: 160, height: 160)
                        ZStack {
                            if showTime == false {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(color)
                                        .matchedGeometryEffect(id: focus.id, in: aniColor)
                                        .frame(width: 100, height: 100)
                                    
                                    Text(focus.emoji)
                                        .font(.system(size: 50))
                                        .matchedGeometryEffect(id: focus.id, in: aniEmoji)
                                }
                            } else {
                                ZStack {
                                    Circle()
                                        .foregroundStyle(color)
                                        .matchedGeometryEffect(id: focus.id, in: aniColor)
                                        .frame(width: 100, height: 100)
                                    
                                    Text("\(secondsConvert(seconds:seconds))")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .scaleEffect(x: -1, y: 1)
                                }
                            }
                        }
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            withAnimation {
                                showTime.toggle()
                            }
                        }
                        .rotation3DEffect(.degrees(showTime ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                    }
                    .padding(.bottom, 10)
                    
                    Text(focus.name)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .matchedGeometryEffect(id: focus.id, in: aniName)
                    
                    if start {
                        VStack {
                            if end == false {
                                HStack {
                                    Spacer()
                                    Button {
                                        withAnimation(.bouncy(duration: 0.5)) {
                                            currentFocus = nil
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .padding(10)
                                    }
                                    .tint(.secondary.opacity(0.3))
                                    .buttonStyle(.borderedProminent)
                                    .clipShape(Circle())
                                    .matchedGeometryEffect(id: focus.id, in: aniXMark)
                                    Spacer()
                                    Button {
                                        playPauseTimer()
                                    } label: {
                                        Image(systemName: timerActive ? "pause.fill" : "play.fill")
                                            .font(.largeTitle)
                                            .padding(10)
                                    }
                                    .tint( timerActive ? .red.opacity(0.3) : .green.opacity(0.3))
                                    .buttonStyle(.borderedProminent)
                                    .clipShape(Circle())
                                    Spacer()
                                }
                                .padding(.bottom)
                            }
                            
                            Text(end == false ? "\"\(focus.quote)\"" : "Done")
                                .multilineTextAlignment(.center)
                                .font(end == false ? .title3 : .title2)
                                .fontWeight(end == false ? .regular : .semibold)
                                .fontDesign(end == false ? .serif : .rounded)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(color.opacity(end == false ? 0.3 : 0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .animation(.bouncy, value: start)
                                .onTapGesture {
                                    withAnimation(.bouncy(duration: 0.5)) {
                                        currentFocus = nil
                                    }
                                }
                        }
                    } else {
                        Button {
                            playPauseTimer()
                        } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "play.fill")
                                    Text("Start Timer")
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                    Spacer()
                                }
                                .frame(height: 40)
                            
                        }
                        .tint(.green.opacity(0.3))
                        .buttonStyle(.borderedProminent)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                }
                Spacer()
            }
            
            Spacer()
        }
        .onReceive(timer) { time in
            guard timerActive else { return }
            if seconds > 0 {
                seconds -= 1
            } else {
                if end != true {
                    withAnimation {
                        if showTime == true {
                            withAnimation {
                                showTime.toggle()
                            }
                        }
                        addSession(focus: focus)
                        end = true
                    }
                }
            }
            
        }
        .toolbar(start == end  || start != end ? .hidden : .visible, for: .tabBar)
        .roundedSection()
    }
    
    func addSession(focus: Focus) {
        focus.sessions.append(Session(name: focus.name, emoji: focus.emoji, seconds: focus.currentTime * 60, start: Date.now, color: [focus.color[0],focus.color[1],focus.color[2]]))
    }
    
    func playPauseTimer() {
        if !start {
            withAnimation(.bouncy) {
                start.toggle()
            }
        }
        
        if showTime == false {
            withAnimation {
                showTime.toggle()
            }
        }
        timerActive.toggle()
    }
    
    func calProgress() -> Double {
        let fullTime: Double = Double(focus.currentTime * 60)
        let lefttime: Double = fullTime - Double(seconds)
        let progress = lefttime / fullTime
        
        return progress
    }
    
    func secondsConvert(seconds: Int) -> (String) {
        let min = (seconds % 3600) / 60
        let sec = (seconds % 3600) % 60
        return "\(min):\(String(format: "%02d", sec))"
    }
}
