import SwiftUI

struct FocusTimerControls: View {
    let focus: Focus
    let color: Color
    let aniColor: Namespace.ID
    let session: FocusTimerSession
    let playPause: () -> Void
    let close: () -> Void

    var body: some View {
        if session.start || session.schedulingAlarm || session.autoStartQueued {
            activeControls
        } else {
            startButton
        }
    }

    private var activeControls: some View {
        VStack(spacing: 14) {
            if session.start {
                Text(session.end ? "Done" : "\"\(focus.quote)\"")
                    .multilineTextAlignment(.center)
                    .font(session.end ? .title3 : .body)
                    .fontWeight(session.end ? .semibold : .regular)
                    .fontDesign(session.end ? .rounded : .serif)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 12)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                    .background(color.opacity(session.end ? 0.28 : 0.14), in: .rect(cornerRadius: 20))
                    .onTapGesture {
                        if session.end {
                            close()
                        }
                    }
                    .transition(.opacity)
            }

            if !session.end {
                HStack(spacing: 12) {
                    stopButton

                    actionButton(
                        title: session.timerActive ? "Pause" : "Play",
                        systemName: session.timerActive ? "pause.fill" : "play.fill"
                    )
                }
                .frame(maxWidth: .infinity)
                .transition(.opacity)
            }
        }
    }

    private var startButton: some View {
        Button(action: playPause) {
            HStack {
                Spacer()
                Image(systemName: "play.fill")
                Text("Start Timer")
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                Spacer()
            }
            .frame(height: 42)
            .foregroundStyle(.black)
        }
        .buttonStyle(.glassProminent)
        .tint(.white)
        .buttonBorderShape(.roundedRectangle(radius: 15))
        .transition(.opacity)
    }

    private func actionButton(title: String, systemName: String) -> some View {
        Button(action: playPause) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.headline)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .foregroundStyle(.black)
        }
        .buttonStyle(.glassProminent)
        .tint(.white)
        .buttonBorderShape(.capsule)
        .matchedGeometryEffect(id: focus.id, in: aniColor, properties: .frame)
        .disabled(session.schedulingAlarm || session.autoStartQueued)
    }

    private var stopButton: some View {
        Button(action: close) {
            HStack(spacing: 8) {
                Image(systemName: "stop.fill")
                    .font(.subheadline)
                Text("Stop")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .foregroundStyle(.primary)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
    }
}
