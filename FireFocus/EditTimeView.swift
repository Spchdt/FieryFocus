//
//  AddNewTimeView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 23/10/2566 BE.
//

import SwiftUI

struct EditTimeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var focus: Focus
    @State private var time = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach (focus.time, id:\.self) { time in
                            Text("\(time) min")
                    }.onDelete(perform: focus.time.count > 1 ? deleteTime : nil)
                } header: {
                    Text("Delete unused time")
                }
                
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
                } header: {
                    Text("Add new time ")
                }
                
                Section {
                    Button(action: {
                        focus.time.append(time)
                        focus.time.sort { $0 < $1 }
                        focus.currentTime = time
                        dismiss()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Add new time")
                                .foregroundStyle(focus.time.contains(time) ? .gray : .accent)
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                            Spacer()
                        }
                        .frame(height: 40)
                    })
                    .disabled(focus.time.contains(time))
                }
                .listRowBackground(
                    focus.time.contains(time) ?
                    Color(UIColor.gray).opacity(0.2)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    : Color.accentColor.opacity(0.2)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                )
                .roundedSection()
            }
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundStyle(.accent)
                }
            }
            .navigationTitle("Edit time")
        }
    }
    
    func deleteTime(at offsets: IndexSet) {
        focus.time.remove(atOffsets: offsets)
    }
}
