import SwiftUI

struct FocusCompactRow: View {
    @Bindable var focus: Focus
    @Binding var timeAlert: Bool

    let isMuted: Bool
    let showsPlayButton: Bool
    let aniColor: Namespace.ID
    let aniEmoji: Namespace.ID
    let aniName: Namespace.ID
    let aniContainer: Namespace.ID
    let startSession: () -> Void

    var body: some View {
        HStack {
            Text(focus.emoji)
                .font(.system(size: 30))
                .shadow(radius: 10)
                .padding()
                .glassEffect(.regular, in: .circle)
                .matchedGeometryEffect(id: focus.id, in: aniEmoji)
                .padding(.trailing, 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(focus.name)
                    .font(.title2)
                    .bold()
                    .matchedGeometryEffect(id: focus.id, in: aniName)

                timeMenu
                    .disabled(isMuted)
                    .opacity(isMuted ? 0.35 : 1)
            }

            Spacer()

            if showsPlayButton {
                Button(action: startSession) {
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.black)
                }
                .buttonStyle(.glassProminent)
                .tint(.white)
                .buttonBorderShape(.circle)
                .matchedGeometryEffect(id: focus.id, in: aniColor, properties: .frame)
                .disabled(isMuted)
                .opacity(isMuted ? 0.35 : 1)
            }
        }
        .matchedGeometryEffect(id: focus.id, in: aniContainer, properties: .position)
    }

    private var timeMenu: some View {
        Menu {
            ForEach(focus.time, id: \.self) { time in
                Button("\(time) min") {
                    focus.currentTime = time
                }
            }

            Button {
                timeAlert.toggle()
            } label: {
                Label("Edit time", systemImage: "square.and.pencil")
            }
        } label: {
            HStack(spacing: 5) {
                Text("\(focus.currentTime) min")
                    .font(.caption)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
            }
            .bold()
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
    }
}
