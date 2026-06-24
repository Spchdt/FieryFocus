import Foundation

struct AppReviewPromptPolicy {
    private let defaults: UserDefaults
    private let appVersion: String
    private let now: () -> Date
    private let minimumCompletedSessions: Int
    private let reviewAttemptCooldown: TimeInterval

    init(
        defaults: UserDefaults = .standard,
        appVersion: String = AppReviewPromptPolicy.currentAppVersion,
        now: @escaping () -> Date = Date.init,
        minimumCompletedSessions: Int = 3,
        reviewAttemptCooldown: TimeInterval = 90 * 24 * 60 * 60
    ) {
        self.defaults = defaults
        self.appVersion = appVersion
        self.now = now
        self.minimumCompletedSessions = minimumCompletedSessions
        self.reviewAttemptCooldown = reviewAttemptCooldown
    }

    func recordCompletedSessionAndConsumeReviewEligibility() -> Bool {
        let completedSessions = defaults.integer(forKey: Keys.completedSessions) + 1
        defaults.set(completedSessions, forKey: Keys.completedSessions)

        guard completedSessions >= minimumCompletedSessions else { return false }
        guard defaults.string(forKey: Keys.lastAttemptedVersion) != appVersion else { return false }

        let attemptDate = now()
        if let lastAttemptDate = defaults.object(forKey: Keys.lastAttemptDate) as? Date,
           attemptDate.timeIntervalSince(lastAttemptDate) < reviewAttemptCooldown {
            return false
        }

        defaults.set(appVersion, forKey: Keys.lastAttemptedVersion)
        defaults.set(attemptDate, forKey: Keys.lastAttemptDate)
        return true
    }

    private static var currentAppVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

    private enum Keys {
        static let completedSessions = "appReviewPrompt.completedSessions"
        static let lastAttemptedVersion = "appReviewPrompt.lastAttemptedVersion"
        static let lastAttemptDate = "appReviewPrompt.lastAttemptDate"
    }
}
