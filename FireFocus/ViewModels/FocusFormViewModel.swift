import SwiftData
import SwiftUI

@MainActor
@Observable
final class FocusFormViewModel {
    var draft: FocusFormDraft
    var isEmojiPickerPresented = false
    var showingDiscardConfirmation = false

    // Editing mode: holds a reference to the Focus being edited
    private let editingFocus: Focus?

    // New-focus mode
    init() {
        self.draft = FocusFormDraft()
        self.editingFocus = nil
    }

    // Edit mode
    init(editing focus: Focus) {
        self.draft = FocusFormDraft(focus: focus)
        self.editingFocus = focus
    }

    // MARK: - Derived

    var canSave: Bool { draft.canSave }

    func hasEditedContent(in environment: EnvironmentValues) -> Bool {
        draft.hasChangesFromDefault(in: environment)
    }

    // MARK: - Actions

    func addFocus(to context: ModelContext, environment: EnvironmentValues) {
        let focus = Focus(
            name: draft.name,
            quote: draft.quote,
            time: draft.timePresets,
            emoji: draft.emoji,
            color: draft.colorComponents(in: environment)
        )
        focus.currentTime = draft.time
        focus.sortOrder = (try? context.fetch(FetchDescriptor<Focus>()).count) ?? 0
        context.insert(focus)
    }

    func saveFocus(environment: EnvironmentValues) {
        guard let focus = editingFocus else { return }
        focus.name = draft.name
        focus.quote = draft.quote
        focus.emoji = draft.emoji
        focus.color = draft.colorComponents(in: environment)
        focus.time = draft.timePresets
        focus.currentTime = draft.time
    }

    func requestDismiss(hasEdits: Bool, dismiss: () -> Void) {
        if hasEdits {
            showingDiscardConfirmation = true
        } else {
            dismiss()
        }
    }
}
