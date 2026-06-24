//
//  NewFocusView.swift
//  FieryFocus
//

import SwiftUI
import SwiftData

struct NewFocusView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.self) private var environment
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = FocusFormViewModel()
    @FocusState private var focusedField: FocusFormField?

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
            .navigationTitle("New Focus")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.requestDismiss(
                            hasEdits: viewModel.hasEditedContent(in: environment),
                            dismiss: { dismiss() }
                        )
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addFocus(to: modelContext, environment: environment)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(!viewModel.canSave)
                    .accessibilityLabel("Add Focus")
                }
            }
            .interactiveDismissDisabled(viewModel.hasEditedContent(in: environment))
            .background(
                DismissAttemptObserver(isEnabled: viewModel.hasEditedContent(in: environment)) {
                    viewModel.showingDiscardConfirmation = true
                }
            )
            .alert("Discard new focus?", isPresented: $viewModel.showingDiscardConfirmation) {
                Button("Keep Editing", role: .cancel) { }
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Your changes will be lost.")
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }
}

#Preview {
    NewFocusView()
}
