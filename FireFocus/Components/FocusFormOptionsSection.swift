import MCEmojiPicker
import SwiftUI
import UIKit

struct FocusFormOptionsSection: View {
    @Binding var emoji: String
    @Binding var color: Color
    @Binding var isEmojiPickerPresented: Bool
    let dismissKeyboard: () -> Void

    var body: some View {
        Section {
            VStack {
                HStack {
                    Text("Emoji")
                        .foregroundStyle(.tertiary)
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 60, height: 60)
                            .foregroundStyle(Color(UIColor.tertiarySystemFill))
                        Text(emoji)
                            .font(.title)
                    }
                    .onTapGesture {
                        dismissKeyboard()
                        isEmojiPickerPresented.toggle()
                    }
                    .emojiPicker(
                        isPresented: $isEmojiPickerPresented,
                        selectedEmoji: $emoji,
                        arrowDirection: .down
                    )
                }
                .frame(height: 70)
                .simultaneousGesture(TapGesture().onEnded(dismissKeyboard))

                Divider()

                HStack {
                    Text("Color")
                        .foregroundStyle(.tertiary)
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 60, height: 60)
                            .foregroundStyle(Color(UIColor.tertiarySystemFill))

                        ColorPicker("", selection: $color)
                            .labelsHidden()
                    }
                }
                .frame(height: 70)
                .simultaneousGesture(TapGesture().onEnded(dismissKeyboard))
            }
        }
        .roundedSection()
    }
}

