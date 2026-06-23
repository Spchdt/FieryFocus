import SwiftUI

struct StatisticMetricsView: View {
    let summary: StatisticSummary

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            StatisticMetricView(
                title: "Sessions",
                value: "\(summary.totalSessions)",
                systemImage: "checkmark.circle.fill"
            )

            StatisticMetricView(
                title: "Focus Time",
                value: StatisticFormatter.durationString(from: summary.totalSeconds),
                systemImage: "timer"
            )

            StatisticMetricView(
                title: "Streak",
                value: "\(summary.currentStreak)d",
                systemImage: "flame.fill"
            )

            StatisticMetricView(
                title: "Average",
                value: StatisticFormatter.durationString(from: summary.averageSeconds),
                systemImage: "chart.line.uptrend.xyaxis"
            )
        }
    }
}

