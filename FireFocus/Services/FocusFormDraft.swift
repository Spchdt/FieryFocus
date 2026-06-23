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
    var emoji: String
    var color: Color

    init(
        name: String = defaultName,
        quote: String = defaultQuote,
        time: Int = defaultTime,
        emoji: String = defaultEmoji,
        color: Color = defaultColor
    ) {
        self.name = name
        self.quote = quote
        self.time = time
        self.emoji = emoji
        self.color = color
    }

    init(focus: Focus) {
        self.init(
            name: focus.name,
            quote: focus.quote,
            time: focus.currentTime,
            emoji: focus.emoji,
            color: focus.getColor()
        )
    }

    var previewName: String {
        name.isEmpty ? "Focus Name" : name
    }

    var canSave: Bool {
        !name.isEmpty && !quote.isEmpty
    }

    func colorComponents(in environment: EnvironmentValues) -> [Float] {
        let component = color.resolve(in: environment)
        return [component.red, component.green, component.blue]
    }

    func hasChangesFromDefault(in environment: EnvironmentValues) -> Bool {
        name.isEmpty == false ||
        quote.isEmpty == false ||
        time != Self.defaultTime ||
        emoji != Self.defaultEmoji ||
        colorHasChangedFromDefault(in: environment)
    }

    private func colorHasChangedFromDefault(in environment: EnvironmentValues) -> Bool {
        let component = color.resolve(in: environment)
        let redChanged = abs(component.red - 1.00) > 0.001
        let greenChanged = abs(component.green - 0.340) > 0.001
        let blueChanged = abs(component.blue - 0.002) > 0.001

        return redChanged || greenChanged || blueChanged
    }
}

