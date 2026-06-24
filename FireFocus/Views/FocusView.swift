//
//  FocusView.swift
//  FieryFocus
//

import SwiftUI
import SwiftData
import StoreKit

struct FocusView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.requestReview) private var requestReview

    @Namespace private var aniColor
    @Namespace private var aniEmoji
    @Namespace private var aniName
    @Namespace private var aniContainer

    @Query(sort: \Focus.sortOrder) var focuses: [Focus]
    @State private var viewModel = FocusListViewModel()

    var body: some View {
        GeometryReader { _ in
            NavigationStack {
                VStack(spacing: 0) {
                    ScrollView {
                        if focuses.isEmpty {
                            FocusEmptyState()
                                .padding(.horizontal)
                                .padding(.top, 42)
                        } else {
                            focusList
                        }
                    }
                    .animation(.bouncy(duration: 0.45), value: viewModel.currentFocus?.id)
                    .animation(.smooth(duration: 0.2), value: focuses.map(\.sortOrder))
                }
                .navigationTitle("Focus")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.isEditing {
                            Button {
                                withAnimation(.bouncy(duration: 0.35)) {
                                    viewModel.isEditing = false
                                }
                            } label: {
                                Image(systemName: "checkmark")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                            .accessibilityLabel("Done")
                        } else {
                            Button("Edit") {
                                withAnimation(.bouncy(duration: 0.35)) {
                                    viewModel.isEditing = true
                                }
                            }
                        }
                    }
                }
                .sheet(item: $viewModel.editingFocus) { focus in
                    EditFocusView(focus: focus)
                }
                .alert("Delete Focus?", isPresented: $viewModel.deleteConfirmationIsPresented) {
                    Button("Cancel", role: .cancel) {
                        viewModel.pendingDeletion = nil
                    }
                    Button("Delete", role: .destructive) {
                        if let focus = viewModel.pendingDeletion {
                            viewModel.deleteFocus(focus, from: focuses, context: modelContext)
                        }
                    }
                } message: {
                    Text(viewModel.deleteConfirmationMessage)
                }
                .onAppear {
                    viewModel.normalizeFocusOrderIfNeeded(focuses)
                    viewModel.restoreActiveFocusState(from: focuses)
                }
            }
        }
    }

    @ViewBuilder
    private var focusList: some View {
        ForEach(viewModel.displayedFocuses(from: focuses)) { focus in
            FocusListItem(
                focus: focus,
                viewModel: viewModel,
                isEditing: viewModel.isEditing,
                rowBackgroundOpacity: rowBackgroundOpacity,
                aniColor: aniColor,
                aniEmoji: aniEmoji,
                aniName: aniName,
                aniContainer: aniContainer,
                startSession: { viewModel.startSession(with: focus) },
                completedSession: { viewModel.completedSession(requestReview: { requestReview() }) },
                edit: { viewModel.editingFocus = focus },
                delete: { viewModel.pendingDeletion = focus },
                reorder: { dragged, target in
                    viewModel.reorderFocus(dragged, before: target, in: focuses)
                }
            )
        }
    }

    private var rowBackgroundOpacity: Double {
        colorScheme == .light ? 0.7 : 0.3
    }
}

// MARK: - List Item

private struct FocusListItem: View {
    @Bindable var focus: Focus
    @Bindable var viewModel: FocusListViewModel

    let isEditing: Bool
    let rowBackgroundOpacity: Double
    let aniColor: Namespace.ID
    let aniEmoji: Namespace.ID
    let aniName: Namespace.ID
    let aniContainer: Namespace.ID
    let startSession: () -> Void
    let completedSession: () -> Void
    let edit: () -> Void
    let delete: () -> Void
    let reorder: (Focus, Focus) -> Void

    var body: some View {
        HStack(spacing: 10) {
            rowContent

            if isEditing && viewModel.currentFocus != focus {
                FocusRowEditActions(edit: edit, delete: delete)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
        .opacity(viewModel.draggedFocus == focus ? 0.55 : 1)
        .draggable(String(describing: focus.id)) {
            dragPreview
        }
        .dropDestination(for: String.self) { _, _ in
            viewModel.draggedFocus = nil
            return true
        } isTargeted: { isTargeted in
            guard isTargeted,
                  let dragged = viewModel.draggedFocus,
                  dragged != focus else { return }
            reorder(dragged, focus)
        }
    }

    private var rowContent: some View {
        FocusRow(
            focus: focus,
            currentFocus: $viewModel.currentFocus,
            isActive: viewModel.currentFocus == focus,
            isMuted: viewModel.currentFocus != nil && viewModel.currentFocus != focus,
            showsPlayButton: !isEditing,
            aniColor: aniColor,
            aniEmoji: aniEmoji,
            aniName: aniName,
            aniContainer: aniContainer,
            startSession: startSession,
            completedSession: completedSession
        )
        .padding()
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: .rect(cornerRadius: 35))
        .background(
            LinearGradient(
                colors: [focus.getColor().opacity(rowBackgroundOpacity), .clear],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: .rect(cornerRadius: 35)
        )
    }

    private var dragPreview: some View {
        HStack(spacing: 10) {
            Text(focus.emoji)
                .font(.title2)
            Text(focus.name)
                .font(.headline)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(.regular, in: .capsule)
        .onAppear {
            viewModel.draggedFocus = focus
        }
    }
}

// MARK: - Empty State

private struct FocusEmptyState: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("No focus yet")
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)

            Text("Tap Create to add your first focus timer.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 24)
        .glassEffect(.regular, in: .rect(cornerRadius: 35))
    }
}

// MARK: - Preview

#Preview {
    FocusView()
        .modelContainer(FocusViewSampleData.container)
}

@MainActor
private enum FocusViewSampleData {
    static let container: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Focus.self, configurations: configuration)

        [
            Focus(name: "Deep Work", quote: "Small fires become bright focus.", time: [25, 45, 60], emoji: "🔥", color: [1.0, 0.32, 0.18]),
            Focus(name: "Study Sprint", quote: "One page, then the next.", time: [20, 30, 50], emoji: "📚", color: [0.25, 0.48, 1.0]),
            Focus(name: "Meditation", quote: "Return to the breath.", time: [5, 10, 15], emoji: "🧘", color: [0.42, 0.78, 0.58]),
            Focus(name: "Inbox Clear", quote: "Touch it once, decide once.", time: [10, 15, 25], emoji: "✉️", color: [0.95, 0.72, 0.24]),
            Focus(name: "Creative Flow", quote: "Make the rough shape first.", time: [30, 60, 90], emoji: "🎨", color: [0.75, 0.38, 0.92]),
            Focus(name: "Reading Hour", quote: "Stay with the sentence.", time: [15, 30, 45], emoji: "📖", color: [0.56, 0.42, 0.9]),
            Focus(name: "Workout Block", quote: "Strong reps, steady breath.", time: [10, 20, 30], emoji: "💪", color: [0.95, 0.18, 0.36]),
            Focus(name: "Planning", quote: "Choose the next clear move.", time: [10, 25, 40], emoji: "🗓️", color: [0.18, 0.68, 0.72])
        ].forEach { container.mainContext.insert($0) }

        return container
    }()
}
