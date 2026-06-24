import SwiftUI

struct FocusTimerControls: View {
    let focus: Focus
    let color: Color
    let aniColor: Namespace.ID
    let viewModel: FocusTimerViewModel
    let playPause: () -> Void
    let close: () -> Void

    var body: some View {
        if viewModel.start || viewModel.schedulingAlarm || viewModel.autoStartQueued {
            activeControls
        } else {
            startButton
        }
    }

    private var activeControls: some View {
        VStack(spacing: 14) {
            if viewModel.start {
                Text(viewModel.end ? "Done" : "\"\(focus.quote)\"")
                    .multilineTextAlignment(.center)
                    .font(viewModel.end ? .title3 : .body)
                    .fontWeight(viewModel.end ? .semibold : .regular)
                    .fontDesign(viewModel.end ? .rounded : .serif)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 12)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                    .background(color.opacity(viewModel.end ? 0.28 : 0.14), in: .rect(cornerRadius: 20))
                    .onTapGesture {
                        if viewModel.end {
                            close()
                        }
                    }
                    .transition(.opacity)
            }

            if !viewModel.end {
                HStack(spacing: 12) {
                    stopButton

                    actionButton(
                        title: viewModel.timerActive ? "Pause" : "Play",
                        systemName: viewModel.timerActive ? "pause.fill" : "play.fill"
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
        .disabled(viewModel.schedulingAlarm || viewModel.autoStartQueued)
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
