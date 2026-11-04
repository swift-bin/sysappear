import AppKit

public enum Appearance: String, Sendable {
    case light
    case dark

    @MainActor
    public static var current: Appearance {
        let effective = NSApplication.shared.effectiveAppearance
        let match = effective.bestMatch(from: [.darkAqua, .aqua])
        return match == .darkAqua ? .dark : .light
    }
}
