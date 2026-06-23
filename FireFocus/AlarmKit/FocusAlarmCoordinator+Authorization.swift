import AlarmKit

@MainActor
extension FocusAlarmCoordinator {
    func requestAuthorization() async throws -> Bool {
        switch alarmManager.authorizationState {
        case .notDetermined:
            return try await alarmManager.requestAuthorization() == .authorized
        case .authorized:
            return true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }
}

