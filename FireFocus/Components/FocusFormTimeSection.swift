import SwiftUI

struct FocusFormTimeSection: View {
    @Binding var time: Int
    @Binding var timePresets: [Int]
    @State private var newPresetHours = 0
    @State private var newPresetMinutes = FocusFormDraft.defaultTime

    let dismissKeyboard: () -> Void

    var body: some View {
        Section {
            ForEach(timePresets, id: \.self) { preset in
                timePresetRow(for: preset)
            }

            addPresetRow
                .simultaneousGesture(TapGesture().onEnded(dismissKeyboard))
        } header: {
            Text("Time Presets")
        } footer: {
            Text("Choose the default time, then add or delete presets for this focus.")
        }
    }

    private func timePresetRow(for preset: Int) -> some View {
        HStack(spacing: 12) {
            Button {
                time = preset
            } label: {
                Image(systemName: time == preset ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(time == preset ? "\(preset.formattedMinutes), default" : "Make \(preset.formattedMinutes) default")

            Text(preset.formattedMinutes)
                .fontWeight(time == preset ? .semibold : .regular)

            Spacer()

            Button(role: .destructive) {
                deletePreset(preset)
            } label: {
                Image(systemName: "trash")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
            .disabled(timePresets.count == 1)
            .accessibilityLabel("Delete \(preset.formattedMinutes) preset")
        }
    }

    private var addPresetRow: some View {
        HStack(spacing: 4) {
            Picker("Hours", selection: $newPresetHours) {
                ForEach(0..<24) { hour in
                    Text("\(hour)").tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100, height: 76)
            .clipped()

            Text("hr")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.trailing, 8)

            Picker("Minutes", selection: $newPresetMinutes) {
                ForEach(0..<60) { minute in
                    Text("\(minute)").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100, height: 76)
            .clipped()

            Text("min")
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                addPreset()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .disabled(isAddDisabled)
            .accessibilityLabel("Add \(newPresetHours) hours and \(newPresetMinutes) minutes preset")
        }
        .frame(height: 76)
    }

    private var isAddDisabled: Bool {
        let totalMinutes = newPresetHours * 60 + newPresetMinutes
        return totalMinutes <= 0 || timePresets.contains(totalMinutes)
    }

    private func addPreset() {
        let totalMinutes = newPresetHours * 60 + newPresetMinutes
        guard totalMinutes > 0, !timePresets.contains(totalMinutes) else { return }
        timePresets.append(totalMinutes)
        timePresets.sort()
        time = totalMinutes
    }

    private func deletePreset(_ preset: Int) {
        guard timePresets.count > 1 else { return }
        timePresets.removeAll { $0 == preset }
        timePresets.sort()

        if time == preset {
            time = timePresets.first ?? FocusFormDraft.defaultTime
        }
    }
}
