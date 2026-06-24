import SwiftUI

struct FocusFormSampleRow: View {
    let name: String
    let time: Int
    let emoji: String
    let color: Color

    var body: some View {
        HStack {
            Text(emoji)
                .font(.system(size: 30))
                .shadow(radius: 10)
                .padding()
                .glassEffect(.regular, in: .circle)
                .padding(.trailing, 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.title2)
                    .bold()

                Button {
                } label: {
                    HStack(spacing: 5) {
                        Text(time.formattedMinutes)
                            .font(.caption)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8))
                    }
                    .bold()
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "play.fill")
                    .font(.title2)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.black)
            }
            .buttonStyle(.glassProminent)
            .tint(.white)
            .buttonBorderShape(.circle)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 35))
        .background(
            LinearGradient(
                colors: [color.opacity(0.3), .clear],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: .rect(cornerRadius: 35)
        )
        .allowsHitTesting(false)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(time.formattedMinutes)")
    }
}
