import Foundation
import SwiftUI

@MainActor
@Observable
final class StatisticViewModel {
    var selectedDate = Date()

    private var focuses: [Focus]

    init(focuses: [Focus]) {
        self.focuses = focuses
    }

    // MARK: - Update

    func update(focuses: [Focus]) {
        self.focuses = focuses
    }

    // MARK: - Derived

    var sessions: [Session] {
        StatisticSessionStore.sessions(from: focuses)
    }

    var filteredSessions: [Session] {
        StatisticSessionStore.sessions(on: selectedDate, from: sessions)
    }

    var summary: StatisticSummary {
        StatisticCalculator.summary(from: sessions)
    }
}
