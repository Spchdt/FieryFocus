import Foundation

enum StatisticCalculator {
    static func summary(
        from sessions: [Session],
        calendar: Calendar = .current,
        today: Date = Date()
    ) -> StatisticSummary {
        let totalSeconds = sessions.reduce(0) { $0 + $1.seconds }

        return StatisticSummary(
            totalSessions: sessions.count,
            totalSeconds: totalSeconds,
            currentStreak: currentStreak(from: sessions, calendar: calendar, today: today),
            averageSeconds: sessions.isEmpty ? 0 : totalSeconds / sessions.count
        )
    }

    private static func currentStreak(from sessions: [Session], calendar: Calendar, today: Date) -> Int {
        let sessionDays = Set(sessions.map { calendar.startOfDay(for: $0.start) })
        var cursor = calendar.startOfDay(for: today)
        var streak = 0

        while sessionDays.contains(cursor) {
            streak += 1

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }

            cursor = previousDay
        }

        return streak
    }
}

