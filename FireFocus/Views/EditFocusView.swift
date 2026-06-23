import SwiftUI

struct EditFocusView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.self) private var environment

    @Bindable var focus: Focus
    @State private var isEmojiPickerPresented = false
    @State private var draft: FocusFormDraft
    @FocusState private var focusedField: FocusFormField?

    init(focus: Focus) {
        self.focus = focus
        self._draft = State(wrappedValue: FocusFormDraft(focus: focus))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FocusFormSampleRow(
                        name: draft.previewName,
                        time: draft.time,
                        emoji: draft.emoji,
                        color: draft.color
                    )
                }
                .padding(-20)
                .listRowBackground(Color.clear)
                .simultaneousGesture(TapGesture().onEnded(dismissKeyboard))

                FocusFormOptionsSection(
                    emoji: $draft.emoji,
                    color: $draft.color,
                    isEmojiPickerPresented: $isEmojiPickerPresented,
                    dismissKeyboard: dismissKeyboard
                )

                FocusFormTextSection(
                    name: $draft.name,
                    quote: $draft.quote,
                    focusedField: $focusedField,
                    dismissKeyboard: dismissKeyboard
                )

                FocusFormTimeSection(time: $draft.time, dismissKeyboard: dismissKeyboard)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit Focus")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveFocus()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(!draft.canSave)
                }
            }
        }
    }

    private func saveFocus() {
        focus.name = draft.name
        focus.quote = draft.quote
        focus.emoji = draft.emoji
        focus.color = draft.colorComponents(in: environment)
        focus.time = [draft.time]
        focus.currentTime = draft.time
    }

    private func dismissKeyboard() {
        focusedField = nil
    }
}

#Preview {
    EditFocusView(
        focus: Focus(
            name: "Deep Work",
            quote: "Small fires become bright focus.",
            time: [25, 45, 60],
            emoji: "🔥",
            color: [1.0, 0.32, 0.18]
        )
    )
}
