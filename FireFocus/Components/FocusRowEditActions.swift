import SwiftUI

struct FocusRowEditActions: View {
    let edit: () -> Void
    let delete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button {
                edit()
            } label: {
                Image(systemName: "pencil")
                    .font(.headline)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Edit focus")

            Spacer()

            Button(role: .destructive) {
                delete()
            } label: {
                Image(systemName: "trash")
                    .font(.headline)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .tint(.red)
            .accessibilityLabel("Delete focus")
        }
    }
}

