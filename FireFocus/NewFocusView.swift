//
//  NewFocusView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import SwiftUI
import MCEmojiPicker

struct NewFocusView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.self) var environment
    @Environment(\.modelContext) var modelContext
    
    @State private var path = [Focus]()
    @State private var isPresented = false
    
    @State private var name: String = ""
    @State private var quote: String = ""
    @State private var time: Int = 3
    
    @State private var emoji: String = "😀"
    @State private var color: Color = Color(red: 1.00, green: 0.340, blue: 0.002)
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .foregroundStyle(color)
                                .frame(width: 100, height: 100)
                            Text(emoji)
                                .font(.system(size: 50))
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section {
                    VStack {
                        TextField("Name", text: $name)
                        Divider()
                        TextField("Quote", text: $quote, axis: .vertical)
                        
                    }
                }
                .roundedSection()
                
                Section {
                    HStack {
                        Text("Time")
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Picker("time", selection: $time) {
                            ForEach(0..<61) {
                                if $0 != 0 {
                                    Text("\($0)")
                                }
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 120)
                        Text("minutes")
                    }
                    .frame(height: 100)
                }
                .roundedSection()
                
                Section {
                    VStack {
                        HStack {
                            Text("Emoji")
                                .foregroundStyle(.tertiary)
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(Color(UIColor.tertiarySystemFill))
                                Text(emoji)
                                    .font(.title)
                            }
                            .onTapGesture {
                                isPresented.toggle()
                            }
                            .emojiPicker(
                                isPresented: $isPresented,
                                selectedEmoji: $emoji,
                                arrowDirection: .down
                            )
                        }
                        .frame(height: 70)
                        Divider()
                        HStack {
                            Text("Color")
                                .foregroundStyle(.tertiary)
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(Color(UIColor.tertiarySystemFill))
                                
                                ColorPicker("", selection: $color)
                                    .labelsHidden()
                            }
                            
                            
                        }
                        .frame(height: 70)
                    }
                }
                .roundedSection()
                
                Section {
                    Button(action: {
                        addFocus()
                        dismiss()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Add New Focus")
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                            Spacer()
                        }
                        .frame(height: 40)
                    }).disabled(name == "" || quote == "")
                }
                .listRowBackground(
                    name == "" || quote == "" ?
                    Color(UIColor.gray).opacity(0.2)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    : Color.accentColor.opacity(0.2)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                )
            }
            .navigationTitle("New Focus")
        }
    }
    
    func addFocus() {
        let component = color.resolve(in: environment)
        let colors = [component.red, component.green, component.blue]
        
        let focus = Focus(name: name, quote: quote, time: [time], emoji: emoji, color: colors)
        modelContext.insert(focus)
        path = [focus]
    }
    
}

#Preview {
    NewFocusView()
}
