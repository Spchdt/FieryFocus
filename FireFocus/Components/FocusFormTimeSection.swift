import SwiftUI

struct FocusFormTimeSection: View {
    @Binding var time: Int
    let dismissKeyboard: () -> Void

    var body: some View {
        Section {
            HStack {
                Text("Time")
                    .foregroundStyle(.tertiary)
                Spacer()
                Picker("time", selection: $time) {
                    ForEach(1..<61) { minute in
                        Text("\(minute)")
                            .tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120, height: 76)
                .clipped()
                Text("minutes")
            }
            .frame(height: 76)
            .simultaneousGesture(TapGesture().onEnded(dismissKeyboard))
        }
        .roundedSection()
    }
}

