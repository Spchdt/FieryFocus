import SwiftUI

struct FocusRowActiveLayout: View {
    @Bindable var focus: Focus
    @Binding var currentFocus: Focus?
    @State private var session: FocusTimerSession

    let aniColor: Namespace.ID
    let aniEmoji: Namespace.ID
    let aniName: Namespace.ID
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let color: Color

    init(
        focus: Focus,
        currentFocus: Binding<Focus?>,
        aniColor: Namespace.ID,
        aniEmoji: Namespace.ID,
        aniName: Namespace.ID,
        color: Color,
        autoStart: Bool
    ) {
        self.focus = focus
        self._currentFocus = currentFocus
        self.aniColor = aniColor
        self.aniEmoji = aniEmoji
        self.aniName = aniName
        self.color = color
        self._session = State(initialValue: FocusTimerSession(
            seconds: focus.currentTime * 60,
            autoStart: autoStart
        ))
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 14) {
                FocusTimerDisplay(
                    focus: focus,
                    color: color,
                    aniEmoji: aniEmoji,
                    showTime: session.showTime,
                    displayedText: session.formattedSeconds(),
                    progress: session.progress(fallbackTotal: focus.currentTime * 60)
                ) {
                    withAnimation(.bouncy(duration: 0.45)) {
                        session.showTime.toggle()
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
                    session: session,
                    playPause: playPauseTimer,
                    close: closeSession
                )
            }
        }
        .padding(.vertical, 8)
        .onReceive(timer, perform: handleTimerTick)
        .onChange(of: session.alarmCoordinator.externalCompletionCount) { _, _ in
            guard session.start, !session.end else { return }
            completeSession()
        }
        .onChange(of: session.alarmCoordinator.externalStopCount) { _, _ in
            guard session.start, !session.end else { return }
            stopSessionFromLiveActivity()
        }
        .onAppear(perform: startAutomaticallyIfNeeded)
        .alert("AlarmKit Error", isPresented: Binding(
            get: { session.alarmErrorMessage != nil },
            set: { if !$0 { session.alarmErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                session.alarmErrorMessage = nil
            }
        } message: {
            Text(session.alarmErrorMessage ?? "")
        }
    }

    private func handleTimerTick(_ time: Date) {
        if session.handleTimerTick(time) {
            completeSession()
        }
    }

    private func playPauseTimer() {
        Task {
            await session.playPauseTimer(focus: focus, color: color)
        }
    }

    private func startAutomaticallyIfNeeded() {
        guard session.consumeAutoStartRequest() else { return }
        playPauseTimer()
    }

    private func completeSession() {
        guard !session.end else { return }

        withAnimation(.bouncy(duration: 0.45)) {
            session.complete(focus: focus)
            currentFocus = nil
        }
    }

    private func closeSession() {
        session.close()
        withAnimation(.bouncy(duration: 0.5)) {
            currentFocus = nil
        }
    }

    private func stopSessionFromLiveActivity() {
        session.stopWithoutRecording()
        withAnimation(.bouncy(duration: 0.5)) {
            currentFocus = nil
        }
    }
}
