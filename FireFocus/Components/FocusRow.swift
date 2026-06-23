import SwiftUI

struct FocusRow: View {
    @Bindable var focus: Focus
    @Binding var currentFocus: Focus?
    @State private var timeAlert = false

    let isActive: Bool
    let isMuted: Bool
    let showsPlayButton: Bool
    let aniColor: Namespace.ID
    let aniEmoji: Namespace.ID
    let aniName: Namespace.ID
    let aniContainer: Namespace.ID
    let startSession: () -> Void

    var body: some View {
        Group {
            if isActive {
                FocusRowActiveLayout(
                    focus: focus,
                    currentFocus: $currentFocus,
                    aniColor: aniColor,
                    aniEmoji: aniEmoji,
                    aniName: aniName,
                    color: focus.getColor(),
                    autoStart: true
                )
                .transition(.opacity)
            } else {
                FocusCompactRow(
                    focus: focus,
                    timeAlert: $timeAlert,
                    isMuted: isMuted,
                    showsPlayButton: showsPlayButton,
                    aniColor: aniColor,
                    aniEmoji: aniEmoji,
                    aniName: aniName,
                    aniContainer: aniContainer,
                    startSession: startSession
                )
                .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.28), value: isActive)
        .sheet(isPresented: $timeAlert) {
            EditTimeView(focus: focus)
        }
    }
}

#Preview("Focus Row") {
    FocusRowPreview()
        .padding()
}

private struct FocusRowPreview: View {
    @Namespace private var aniColor
    @Namespace private var aniEmoji
    @Namespace private var aniName
    @Namespace private var aniContainer

    @State private var focus = Focus(
        name: "Deep Work",
        quote: "Small fires become bright focus.",
        time: [25, 45, 60],
        emoji: "🔥",
        color: [1.0, 0.32, 0.18]
    )
    @State private var currentFocus: Focus?

    var body: some View {
        FocusRow(
            focus: focus,
            currentFocus: $currentFocus,
            isActive: currentFocus == focus,
            isMuted: false,
            showsPlayButton: true,
            aniColor: aniColor,
            aniEmoji: aniEmoji,
            aniName: aniName,
            aniContainer: aniContainer
        ) {
            currentFocus = focus
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 35))
        .background(
            LinearGradient(
                colors: [focus.getColor().opacity(0.3), .clear],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: .rect(cornerRadius: 35)
        )
    }
}
