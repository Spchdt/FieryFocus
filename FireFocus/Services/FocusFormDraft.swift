import SwiftUI

struct FocusFormDraft {
    static let defaultName = ""
    static let defaultQuote = ""
    static let defaultTime = 3
    static let defaultEmoji = "😀"
    static let defaultColor = Color(red: 1.00, green: 0.340, blue: 0.002)

    var name: String
    var quote: String
    var time: Int
    var timePresets: [Int]
    var emoji: String
    var color: Color

    init(
        name: String = defaultName,
        quote: String = defaultQuote,
        time: Int = defaultTime,
        timePresets: [Int] = [defaultTime],
        emoji: String = defaultEmoji,
        color: Color = defaultColor
    ) {
        let resolvedTime = time > 0 ? time : Self.defaultTime

        self.name = name
        self.quote = quote
        self.time = resolvedTime
        self.timePresets = Self.normalizedTimePresets(timePresets, selectedTime: resolvedTime)
        self.emoji = emoji
        self.color = color
    }

    init(focus: Focus) {
        self.init(
            name: focus.name,
            quote: focus.quote,
            time: focus.currentTime,
            timePresets: focus.time,
            emoji: focus.emoji,
            color: focus.getColor()
        )
    }

    var previewName: String {
        name.isEmpty ? "Focus Name" : name
    }

    var canSave: Bool {
        !name.isEmpty && !quote.isEmpty && !timePresets.isEmpty
    }

    func colorComponents(in environment: EnvironmentValues) -> [Float] {
        let component = color.resolve(in: environment)
        return [component.red, component.green, component.blue]
    }

    func hasChangesFromDefault(in environment: EnvironmentValues) -> Bool {
        name.isEmpty == false ||
        quote.isEmpty == false ||
        time != Self.defaultTime ||
        timePresets != [Self.defaultTime] ||
        emoji != Self.defaultEmoji ||
        colorHasChangedFromDefault(in: environment)
    }

    private static func normalizedTimePresets(_ presets: [Int], selectedTime: Int) -> [Int] {
        var normalizedPresets = presets.filter { $0 > 0 }

        if selectedTime > 0 && !normalizedPresets.contains(selectedTime) {
            normalizedPresets.insert(selectedTime, at: 0)
        }

        var seenPresets = Set<Int>()
        normalizedPresets = normalizedPresets.filter { seenPresets.insert($0).inserted }

        normalizedPresets.sort()

        return normalizedPresets.isEmpty ? [defaultTime] : normalizedPresets
    }

    private func colorHasChangedFromDefault(in environment: EnvironmentValues) -> Bool {
        let component = color.resolve(in: environment)
        let redChanged = abs(component.red - 1.00) > 0.001
        let greenChanged = abs(component.green - 0.340) > 0.001
        let blueChanged = abs(component.blue - 0.002) > 0.001

        return redChanged || greenChanged || blueChanged
    }
}
