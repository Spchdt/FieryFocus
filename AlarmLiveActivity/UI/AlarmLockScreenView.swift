import ActivityKit
import AlarmKit
import SwiftUI

struct AlarmLockScreenView: View {
    let attributes: AlarmAttributes<FocusAlarmMetadata>
    let state: AlarmPresentationState

    var body: some View {
        AlarmLiveActivityRow(attributes: attributes, state: state, compact: true)
            .padding()
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
    }
}
