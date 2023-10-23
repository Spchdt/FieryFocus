//
//  CalendarView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query var focuses: [Focus]
    
    @State var sessionss = [Session]()
    @State var filteredSession = [Session]()
    
    @State private var date = Date()
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Start Date",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                }
                .roundedSection()
                
                Section {
                    ZStack {
                        if filteredSession.count == 0 {
                            HStack {
                                Spacer()
                                Text("Nothing to see on this date")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .fontDesign(.rounded)
                                Spacer()
                            }
                            
                        } else {
                            VStack {
                                ForEach(filteredSession) { session in
                                    
                                    let color = Color(red: Double(session.color[0]), green: Double(session.color[1]), blue: Double(session.color[2]))
                                    
                                    VStack(spacing: 0) {
                                        HStack {
                                            Text("\(showTime(time: session.start)) - \(showTime(time: session.start.addingTimeInterval(TimeInterval(session.seconds))))")
                                                .fontWeight(.medium)
                                                .fontDesign(.rounded)
                                            Spacer()
                                        }
                                        .padding(.bottom, 5)
                                        HStack {
                                            Capsule()
                                                .frame(width: 10, height: 70)
                                                .foregroundStyle(color)
                                            HStack {
                                                Text(session.emoji)
                                                    .font(.system(size: 35))
                                                    .padding(.leading, 10)
                                                
                                                Text(session.name)
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .fontDesign(.rounded)
                                                
                                                Spacer()
                                                
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .frame(width: 80, height: 40)
                                                        .foregroundStyle(color.opacity(0.5))
                                                    
                                                    Text("\(session.seconds / 60) min")
                                                        .fontWeight(.semibold)
                                                        .fontDesign(.rounded)
                                                }
                                                .padding(.trailing, 15)
                                            }
                                            .frame(height: 70)
                                            .frame(maxWidth: .infinity)
                                            .background(color.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                        }
                                    }
                                    .padding(.bottom, 15)
                                    
                                    
                                }
                            }
                        
                            
                        }
                    }
                }
                .frame(minHeight: 100)
                .roundedSection()
            }
            .onChange(of: date) {
                withAnimation {
                    filteredSession = sessionss.filter {Calendar.current.isDate(date, equalTo: $0.start, toGranularity: .day)
                    }
                }
                
            }
            .navigationTitle("History")
        }
        .onAppear {
            sessionss = []
            for focus in focuses {
                for session in focus.sessions {
                    sessionss.append(session)
                }
            }
            sessionss.sort {
                $0.start < $1.start
            }
            filteredSession = sessionss.filter {Calendar.current.isDate(date, equalTo: $0.start, toGranularity: .day)
            }
        }
    }
    
    func showTime(time: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.timeStyle = .short
        return formatter1.string(from: time)
    }
}

#Preview {
    HistoryView()
}
