import SwiftUI

struct FocusTimerDisplay: View {
    let focus: Focus
    let color: Color
    let aniEmoji: Namespace.ID
    let showTime: Bool
    let displayedText: String
    let progress: Double
    let toggleDisplay: () -> Void

    var body: some View {
        Button(action: toggleDisplay) {
            ZStack {
                CircularProgressView(progress: progress, color: color)
                    .frame(width: 158, height: 158)
                    .transaction { transaction in
                        transaction.animation = nil
                    }

                ZStack {
                    if showTime {
                        Text(displayedText)
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Text(focus.emoji)
                            .font(.system(size: 50))
                            .shadow(radius: 10)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 102, height: 102)
                .glassEffect(.regular, in: .circle)
                .matchedGeometryEffect(id: focus.id, in: aniEmoji)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showTime ? "Show focus emoji" : "Show timer")
    }
}
