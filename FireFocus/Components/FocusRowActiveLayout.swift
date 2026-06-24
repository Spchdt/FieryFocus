import SwiftUI

struct FocusRowActiveLayout: View {
    @Bindable var focus: Focus
    @Binding var currentFocus: Focus?
    @State private var viewModel: FocusTimerViewModel

    let aniColor: Namespace.ID
    let aniEmoji: Namespace.ID
    let aniName: Namespace.ID
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let color: Color
    let completedSession: () -> Void

    init(
        focus: Focus,
        currentFocus: Binding<Focus?>,
        aniColor: Namespace.ID,
        aniEmoji: Namespace.ID,
        aniName: Namespace.ID,
        color: Color,
        autoStart: Bool,
        completedSession: @escaping () -> Void
    ) {
        self.focus = focus
        self._currentFocus = currentFocus
        self.aniColor = aniColor
        self.aniEmoji = aniEmoji
        self.aniName = aniName
        self.color = color
        self.completedSession = completedSession

        let isRestoring = FocusAlarmCoordinator.activeAlarmFocusName == focus.name
        self._viewModel = State(initialValue: FocusTimerViewModel(
            seconds: focus.currentTime * 60,
            autoStart: isRestoring ? false : autoStart,
            isRestoring: isRestoring
        ))
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 14) {
                FocusTimerDisplay(
                    focus: focus,
                    color: color,
                    aniEmoji: aniEmoji,
                    showTime: viewModel.showTime,
                    displayedText: viewModel.formattedSeconds(),
                    progress: viewModel.progress(fallbackTotal: focus.currentTime * 60)
                ) {
                    withAnimation(.bouncy(duration: 0.45)) {
                        viewModel.showTime.toggle()
                    }
                }

                Text(focus.name)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWeight(.bold)
                    .matchedGeometryEffect(id: focus.id, in: aniName)

                FocusTimerControls(
                    focus: focus,
                    color: color,
                    aniColor: aniColor,
                    viewModel: viewModel,
                    playPause: playPauseTimer,
                    close: closeSession
                )
            }
        }
        .padding(.vertical, 8)
        .onReceive(timer, perform: handleTimerTick)
        .onChange(of: viewModel.alarmCoordinator.externalCompletionCount) { _, _ in
            guard viewModel.start, !viewModel.end else { return }
            completeSession()
        }
        .onChange(of: viewModel.alarmCoordinator.externalStopCount) { _, _ in
            guard viewModel.start, !viewModel.end else { return }
            stopSessionFromLiveActivity()
        }
        .onAppear(perform: startAutomaticallyIfNeeded)
        .alert("AlarmKit Error", isPresented: Binding(
            get: { viewModel.alarmErrorMessage != nil },
            set: { if !$0 { viewModel.alarmErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.alarmErrorMessage = nil
            }
        } message: {
            Text(viewModel.alarmErrorMessage ?? "")
        }
    }

    private func handleTimerTick(_ time: Date) {
        if viewModel.handleTimerTick(time) {
            completeSession()
        }
    }

    private func playPauseTimer() {
        Task {
            let didStartOrToggle = await viewModel.togglePlayPause(focus: focus, color: color)
            guard !didStartOrToggle, !viewModel.start else { return }

            withAnimation(.bouncy(duration: 0.5)) {
                currentFocus = nil
            }
        }
    }

    private func startAutomaticallyIfNeeded() {
        guard viewModel.autoStartQueued else { return }
        playPauseTimer()
    }

    private func completeSession() {
        guard !viewModel.end else { return }

        withAnimation(.bouncy(duration: 0.45)) {
            viewModel.complete(focus: focus)
            currentFocus = nil
        }
        completedSession()
    }

    private func closeSession() {
        viewModel.close()
        withAnimation(.bouncy(duration: 0.5)) {
            currentFocus = nil
        }
    }

    private func stopSessionFromLiveActivity() {
        viewModel.stopWithoutRecording()
        withAnimation(.bouncy(duration: 0.5)) {
            currentFocus = nil
        }
    }
}
