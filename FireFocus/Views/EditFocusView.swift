import SwiftUI

struct EditFocusView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.self) private var environment

    @Bindable var focus: Focus
    @State private var viewModel: FocusFormViewModel
    @FocusState private var focusedField: FocusFormField?

    init(focus: Focus) {
        self.focus = focus
        self._viewModel = State(wrappedValue: FocusFormViewModel(editing: focus))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FocusFormSampleRow(
                        name: viewModel.draft.previewName,
                        time: viewModel.draft.time,
                        emoji: viewModel.draft.emoji,
                        color: viewModel.draft.color
                    )
                }
                .padding(-20)
                .listRowBackground(Color.clear)
                .simultaneousGesture(TapGesture().onEnded(dismissKeyboard))

                FocusFormTextSection(
                    name: $viewModel.draft.name,
                    quote: $viewModel.draft.quote,
                    focusedField: $focusedField,
                    dismissKeyboard: dismissKeyboard
                )

                FocusFormOptionsSection(
                    emoji: $viewModel.draft.emoji,
                    color: $viewModel.draft.color,
                    isEmojiPickerPresented: $viewModel.isEmojiPickerPresented,
                    dismissKeyboard: dismissKeyboard
                )

                FocusFormTimeSection(
                    time: $viewModel.draft.time,
                    timePresets: $viewModel.draft.timePresets,
                    dismissKeyboard: dismissKeyboard
                )
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
                    Button {
                        viewModel.saveFocus(environment: environment)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(!viewModel.canSave)
                    .accessibilityLabel("Done")
                }
            }
        }
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
