//
//  NewFocusView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import SwiftUI
import SwiftData

struct NewFocusView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.self) private var environment
    @Environment(\.modelContext) private var modelContext
    
    @State private var isPresented = false
    @State private var showingDiscardConfirmation = false

    @State private var draft = FocusFormDraft()
    @FocusState private var focusedField: FocusFormField?
    
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
                    isEmojiPickerPresented: $isPresented,
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
            .navigationTitle("New Focus")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        requestDismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addFocus()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(!draft.canSave)
                }
            }
            .interactiveDismissDisabled(hasEditedContent)
            .background(
                DismissAttemptObserver(isEnabled: hasEditedContent) {
                    showingDiscardConfirmation = true
                }
            )
            .alert("Discard new focus?", isPresented: $showingDiscardConfirmation) {
                Button("Keep Editing", role: .cancel) { }
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Your changes will be lost.")
            }
        }
    }

    private var hasEditedContent: Bool {
        draft.hasChangesFromDefault(in: environment)
    }

    private func requestDismiss() {
        if hasEditedContent {
            showingDiscardConfirmation = true
        } else {
            dismiss()
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }

    private func addFocus() {
        let focus = Focus(
            name: draft.name,
            quote: draft.quote,
            time: [draft.time],
            emoji: draft.emoji,
            color: draft.colorComponents(in: environment)
        )
        focus.sortOrder = (try? modelContext.fetch(FetchDescriptor<Focus>()).count) ?? 0
        modelContext.insert(focus)
    }
}

#Preview {
    NewFocusView()
}
