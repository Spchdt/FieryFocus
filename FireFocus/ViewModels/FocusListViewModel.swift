import SwiftData
import SwiftUI

@MainActor
@Observable
final class FocusListViewModel {
    var currentFocus: Focus?
    var editingFocus: Focus?
    var pendingDeletion: Focus?
    var draggedFocus: Focus?
    var isEditing = false

    private let appReviewPromptPolicy = AppReviewPromptPolicy()

    // MARK: - Derived

    func displayedFocuses(from focuses: [Focus]) -> [Focus] {
        guard
            let currentFocus,
            focuses.contains(where: { $0.id == currentFocus.id })
        else {
            return focuses
        }
        return [currentFocus] + focuses.filter { $0.id != currentFocus.id }
    }

    var deleteConfirmationIsPresented: Bool {
        get { pendingDeletion != nil }
        set { if !newValue { pendingDeletion = nil } }
    }

    var deleteConfirmationMessage: String {
        guard let pendingDeletion else {
            return "Saved sessions will also be deleted."
        }
        return "\"\(pendingDeletion.name)\" and its saved sessions will be deleted."
    }

    // MARK: - Actions

    func startSession(with focus: Focus) {
        guard currentFocus == nil || currentFocus == focus else { return }
        withAnimation(.bouncy(duration: 0.5)) {
            currentFocus = focus
        }
    }

    func completedSession(requestReview: @escaping () -> Void) {
        guard appReviewPromptPolicy.recordCompletedSessionAndConsumeReviewEligibility() else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.7))
            requestReview()
        }
    }

    func reorderFocus(_ dragged: Focus, before target: Focus, in focuses: [Focus]) {
        guard currentFocus == nil, dragged != target else { return }
        var orderedFocuses = focuses
        guard
            let fromIndex = orderedFocuses.firstIndex(of: dragged),
            let toIndex = orderedFocuses.firstIndex(of: target),
            fromIndex != toIndex
        else { return }

        withAnimation(.smooth(duration: 0.2)) {
            let movedFocus = orderedFocuses.remove(at: fromIndex)
            orderedFocuses.insert(movedFocus, at: toIndex)
            updateFocusOrder(orderedFocuses)
        }
    }

    func normalizeFocusOrderIfNeeded(_ focuses: [Focus]) {
        let needsOrderUpdate = focuses.enumerated().contains { index, focus in
            focus.sortOrder != index
        }
        guard needsOrderUpdate else { return }
        updateFocusOrder(focuses)
    }

    func deleteFocus(_ focus: Focus, from focuses: [Focus], context: ModelContext) {
        if currentFocus == focus { currentFocus = nil }
        if editingFocus == focus { editingFocus = nil }

        let remaining = focuses.filter { $0 != focus }
        context.delete(focus)
        updateFocusOrder(remaining)
    }

    func restoreActiveFocusState(from focuses: [Focus]) {
        guard currentFocus == nil else { return }
        if let activeName = FocusAlarmCoordinator.activeAlarmFocusName,
           let matched = focuses.first(where: { $0.name == activeName }) {
            withAnimation(.bouncy(duration: 0.5)) {
                currentFocus = matched
            }
        }
    }

    // MARK: - Private

    private func updateFocusOrder(_ orderedFocuses: [Focus]) {
        for (index, focus) in orderedFocuses.enumerated() {
            focus.sortOrder = index
        }
    }
}
