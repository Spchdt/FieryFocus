import ActivityKit
import AlarmKit
import SwiftUI

struct AlarmExpandedIslandView: View {
    let attributes: AlarmAttributes<FocusAlarmMetadata>
    let state: AlarmPresentationState

    var body: some View {
        AlarmLiveActivityRow(attributes: attributes, state: state, compact: false)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
    }
}
