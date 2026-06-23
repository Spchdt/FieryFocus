//
//  HomeVIew.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import SwiftUI
import SwiftData

struct FocusView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @Namespace private var aniColor
    @Namespace private var aniEmoji
    @Namespace private var aniName
    @Namespace private var aniContainer

    @Query(sort: \Focus.sortOrder) var focuses: [Focus]
    @State private var currentFocus: Focus?
    @State private var editingFocus: Focus?
    @State private var pendingDeletion: Focus?
    @State private var draggedFocus: Focus?
    @State private var isEditing = false

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
                    .animation(.bouncy(duration: 0.45), value: currentFocus?.id)
                    .animation(.smooth(duration: 0.2), value: focuses.map(\.sortOrder))
                }
                .navigationTitle("Focus")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if isEditing {
                            Button("Done") {
                                withAnimation(.bouncy(duration: 0.35)) {
                                    isEditing = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                        } else {
                            Button("Edit") {
                                withAnimation(.bouncy(duration: 0.35)) {
                                    isEditing = true
                                }
                            }
                        }
                    }
                }
                .sheet(item: $editingFocus) { focus in
                    EditFocusView(focus: focus)
                }
                .alert("Delete Focus?", isPresented: deleteConfirmationBinding) {
                    Button("Cancel", role: .cancel) {
                        pendingDeletion = nil
                    }
                    Button("Delete", role: .destructive) {
                        if let pendingDeletion {
                            deleteFocus(pendingDeletion)
                        }
                        pendingDeletion = nil
                    }
                } message: {
                    Text(deleteConfirmationMessage)
                }
                .onAppear(perform: normalizeFocusOrderIfNeeded)
            }
        }
    }

    @ViewBuilder
    private var focusList: some View {
        ForEach(displayedFocuses) { focus in
            FocusListItem(
                focus: focus,
                currentFocus: $currentFocus,
                draggedFocus: $draggedFocus,
                isEditing: isEditing,
                rowBackgroundOpacity: rowBackgroundOpacity,
                aniColor: aniColor,
                aniEmoji: aniEmoji,
                aniName: aniName,
                aniContainer: aniContainer,
                startSession: { startSession(with: focus) },
                edit: { editingFocus = focus },
                delete: { pendingDeletion = focus },
                reorder: reorderFocus
            )
        }
    }
    
    private var rowBackgroundOpacity: Double {
        colorScheme == .light ? 0.7 : 0.3
    }
    
    private var displayedFocuses: [Focus] {
        guard
            let currentFocus,
            focuses.contains(where: { $0.id == currentFocus.id })
        else {
            return focuses
        }
        
        return [currentFocus] + focuses.filter { $0.id != currentFocus.id }
    }

    private var deleteConfirmationBinding: Binding<Bool> {
        Binding(
            get: { pendingDeletion != nil },
            set: { if !$0 { pendingDeletion = nil } }
        )
    }

    private var deleteConfirmationMessage: String {
        guard let pendingDeletion else {
            return "Saved sessions will also be deleted."
        }

        return "\"\(pendingDeletion.name)\" and its saved sessions will be deleted."
    }

    private func startSession(with focus: Focus) {
        guard currentFocus == nil || currentFocus == focus else { return }

        withAnimation(.bouncy(duration: 0.5)) {
            currentFocus = focus
        }
    }

    private func reorderFocus(_ dragged: Focus, before target: Focus) {
        guard currentFocus == nil, dragged != target else { return }

        var orderedFocuses = focuses
        guard
            let fromIndex = orderedFocuses.firstIndex(of: dragged),
            let toIndex = orderedFocuses.firstIndex(of: target),
            fromIndex != toIndex
        else {
            return
        }

        withAnimation(.smooth(duration: 0.2)) {
            let movedFocus = orderedFocuses.remove(at: fromIndex)
            orderedFocuses.insert(movedFocus, at: toIndex)
            updateFocusOrder(orderedFocuses)
        }
    }

    private func normalizeFocusOrderIfNeeded() {
        let needsOrderUpdate = focuses.enumerated().contains { index, focus in
            focus.sortOrder != index
        }

        guard needsOrderUpdate else { return }
        updateFocusOrder(focuses)
    }

    private func updateFocusOrder(_ orderedFocuses: [Focus]) {
        for (index, focus) in orderedFocuses.enumerated() {
            focus.sortOrder = index
        }
    }

    private func deleteFocus(_ focus: Focus) {
        if currentFocus == focus {
            currentFocus = nil
        }

        if editingFocus == focus {
            editingFocus = nil
        }

        let remainingFocuses = focuses.filter { $0 != focus }
        modelContext.delete(focus)
        updateFocusOrder(remainingFocuses)
    }
}

private struct FocusListItem: View {
    @Bindable var focus: Focus
    @Binding var currentFocus: Focus?
    @Binding var draggedFocus: Focus?

    let isEditing: Bool
    let rowBackgroundOpacity: Double
    let aniColor: Namespace.ID
    let aniEmoji: Namespace.ID
    let aniName: Namespace.ID
    let aniContainer: Namespace.ID
    let startSession: () -> Void
    let edit: () -> Void
    let delete: () -> Void
    let reorder: (Focus, Focus) -> Void

    var body: some View {
        HStack(spacing: 10) {
            rowContent

            if isEditing && currentFocus != focus {
                FocusRowEditActions(edit: edit, delete: delete)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
        .opacity(draggedFocus == focus ? 0.55 : 1)
        .draggable(focusDragIdentifier) {
            dragPreview
        }
        .dropDestination(for: String.self) { _, _ in
            draggedFocus = nil
            return true
        } isTargeted: { isTargeted in
            guard isTargeted, let draggedFocus, draggedFocus != focus else { return }
            reorder(draggedFocus, focus)
        }
    }

    private var rowContent: some View {
        FocusRow(
            focus: focus,
            currentFocus: $currentFocus,
            isActive: currentFocus == focus,
            isMuted: currentFocus != nil && currentFocus != focus,
            showsPlayButton: !isEditing,
            aniColor: aniColor,
            aniEmoji: aniEmoji,
            aniName: aniName,
            aniContainer: aniContainer,
            startSession: startSession
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
            draggedFocus = focus
        }
    }

    private var focusDragIdentifier: String {
        String(describing: focus.id)
    }
}

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
            Focus(
                name: "Deep Work",
                quote: "Small fires become bright focus.",
                time: [25, 45, 60],
                emoji: "🔥",
                color: [1.0, 0.32, 0.18]
            ),
            Focus(
                name: "Study Sprint",
                quote: "One page, then the next.",
                time: [20, 30, 50],
                emoji: "📚",
                color: [0.25, 0.48, 1.0]
            ),
            Focus(
                name: "Meditation",
                quote: "Return to the breath.",
                time: [5, 10, 15],
                emoji: "🧘",
                color: [0.42, 0.78, 0.58]
            ),
            Focus(
                name: "Inbox Clear",
                quote: "Touch it once, decide once.",
                time: [10, 15, 25],
                emoji: "✉️",
                color: [0.95, 0.72, 0.24]
            ),
            Focus(
                name: "Creative Flow",
                quote: "Make the rough shape first.",
                time: [30, 60, 90],
                emoji: "🎨",
                color: [0.75, 0.38, 0.92]
            ),
            Focus(
                name: "Reading Hour",
                quote: "Stay with the sentence.",
                time: [15, 30, 45],
                emoji: "📖",
                color: [0.56, 0.42, 0.9]
            ),
            Focus(
                name: "Workout Block",
                quote: "Strong reps, steady breath.",
                time: [10, 20, 30],
                emoji: "💪",
                color: [0.95, 0.18, 0.36]
            ),
            Focus(
                name: "Planning",
                quote: "Choose the next clear move.",
                time: [10, 25, 40],
                emoji: "🗓️",
                color: [0.18, 0.68, 0.72]
            )
        ].forEach { focus in
            container.mainContext.insert(focus)
        }

        return container
    }()
}
