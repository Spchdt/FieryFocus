//
//  CalendarView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import SwiftUI
import SwiftData

struct StatisticView: View {
    @Query var focuses: [Focus]
    
    @State private var date = Date()
    
    private var sessionss: [Session] {
        StatisticSessionStore.sessions(from: focuses)
    }
    
    private var filteredSession: [Session] {
        StatisticSessionStore.sessions(on: date, from: sessionss)
    }
    
    private var summary: StatisticSummary {
        StatisticCalculator.summary(from: sessionss)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                StatisticMetricsView(summary: summary)
                    .padding(.horizontal)
                
                
                HStack {
                    Text("Daily Sessions")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                }
                .padding([.horizontal, .top])
                .padding(.bottom, -1)
                    
                DatePicker(
                    "Start Date",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .glassEffect(in: .rect(cornerRadius: 35))
                .padding([.horizontal, .bottom])
                
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
                                StatisticSessionRow(session: session)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Statistic")
        }
    }
}

#Preview {
    StatisticView()
        .modelContainer(StatisticPreviewData.container)
}

@MainActor
private enum StatisticPreviewData {
    static let container: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Focus.self, configurations: configuration)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let deepWork = Focus(
            name: "Deep Work",
            quote: "Small fires become bright focus.",
            time: [25, 45, 60],
            emoji: "🔥",
            color: [1.0, 0.32, 0.18]
        )
        addSessions(
            to: deepWork,
            sessions: [
                (dayOffset: 0, hour: 9, minute: 15, duration: 45),
                (dayOffset: -1, hour: 10, minute: 0, duration: 25),
                (dayOffset: -2, hour: 8, minute: 45, duration: 50)
            ],
            today: today,
            calendar: calendar
        )

        let study = Focus(
            name: "Study Sprint",
            quote: "One page, then the next.",
            time: [20, 30, 50],
            emoji: "📚",
            color: [0.25, 0.48, 1.0]
        )
        addSessions(
            to: study,
            sessions: [
                (dayOffset: 0, hour: 14, minute: 30, duration: 30),
                (dayOffset: -1, hour: 16, minute: 10, duration: 20),
                (dayOffset: -3, hour: 13, minute: 0, duration: 50)
            ],
            today: today,
            calendar: calendar
        )

        let meditation = Focus(
            name: "Meditation",
            quote: "Return to the breath.",
            time: [5, 10, 15],
            emoji: "🧘",
            color: [0.42, 0.78, 0.58]
        )
        addSessions(
            to: meditation,
            sessions: [
                (dayOffset: 0, hour: 7, minute: 20, duration: 10),
                (dayOffset: -1, hour: 7, minute: 10, duration: 15),
                (dayOffset: -2, hour: 7, minute: 30, duration: 10)
            ],
            today: today,
            calendar: calendar
        )

        let creative = Focus(
            name: "Creative Flow",
            quote: "Make the rough shape first.",
            time: [30, 60, 90],
            emoji: "🎨",
            color: [0.75, 0.38, 0.92]
        )
        addSessions(
            to: creative,
            sessions: [
                (dayOffset: -3, hour: 18, minute: 0, duration: 60),
                (dayOffset: -4, hour: 17, minute: 45, duration: 30)
            ],
            today: today,
            calendar: calendar
        )

        [deepWork, study, meditation, creative].forEach { focus in
            container.mainContext.insert(focus)
        }

        return container
    }()

    private static func addSessions(
        to focus: Focus,
        sessions: [(dayOffset: Int, hour: Int, minute: Int, duration: Int)],
        today: Date,
        calendar: Calendar
    ) {
        for session in sessions {
            let day = calendar.date(byAdding: .day, value: session.dayOffset, to: today) ?? today
            let start = calendar.date(
                bySettingHour: session.hour,
                minute: session.minute,
                second: 0,
                of: day
            ) ?? day

            focus.appendSession(
                Session(
                    name: focus.name,
                    emoji: focus.emoji,
                    seconds: session.duration * 60,
                    start: start,
                    color: focus.color
                )
            )
        }
    }
}
