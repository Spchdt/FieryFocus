import SwiftUI

struct StatisticSessionRow: View {
    let session: Session

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(showTime(time: session.start)) - \(showTime(time: session.start.addingTimeInterval(TimeInterval(session.seconds))))")
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                Spacer()
            }
            .padding(.bottom, 5)

            HStack {
                Capsule()
                    .frame(width: 10, height: 70)
                    .glassEffect(.regular.tint(session.getColor()), in:.capsule)

                HStack {
                    Text(session.emoji)
                        .font(.system(size: 35))
                        .padding(.leading, 10)

                    Text(session.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)

                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(session.getColor().opacity(0.5))

                        Text((session.seconds / 60).formattedMinutes)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .padding(.horizontal, 10)
                    }
                    .frame(minWidth: 80, minHeight: 40, maxHeight: 40)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.trailing, 15)
                }
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(session.getColor().opacity(0.5)), in:.rect(cornerRadius: 20))
            }
        }
        .padding(.bottom, 15)
    }

    private func showTime(time: Date) -> String {
        StatisticSessionRowFormatter.timeString(from: time)
    }
}

private enum StatisticSessionRowFormatter {
    static func timeString(from time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
