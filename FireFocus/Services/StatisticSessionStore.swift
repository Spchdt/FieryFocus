import Foundation

enum StatisticSessionStore {
    static func sessions(from focuses: [Focus]) -> [Session] {
        focuses
            .flatMap(\.savedSessions)
            .sorted { $0.start < $1.start }
    }

    static func sessions(on date: Date, from sessions: [Session], calendar: Calendar = .current) -> [Session] {
        sessions.filter {
            calendar.isDate(date, equalTo: $0.start, toGranularity: .day)
        }
    }
}
