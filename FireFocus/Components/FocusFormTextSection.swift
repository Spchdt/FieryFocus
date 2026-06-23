import SwiftUI

struct FocusFormTextSection: View {
    @Binding var name: String
    @Binding var quote: String
    let focusedField: FocusState<FocusFormField?>.Binding
    let dismissKeyboard: () -> Void

    var body: some View {
        Section {
            VStack {
                TextField("Name", text: $name)
                    .focused(focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField.wrappedValue = .quote
                    }
                Divider()
                TextField("Quote", text: $quote, axis: .vertical)
                    .focused(focusedField, equals: .quote)
                    .submitLabel(.done)
                    .onSubmit {
                        dismissKeyboard()
                    }
            }
        }
        .roundedSection()
    }
}

