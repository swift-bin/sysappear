import AppKit
import Foundation

@MainActor
public final class AppearanceObserver: NSObject {
    private static let themeNotification = Notification.Name(
        "AppleInterfaceThemeChangedNotification"
    )

    private var appearanceObservation: NSKeyValueObservation?
    private var onChange: ((Appearance) -> Void)?
    private var lastAppearance: Appearance?
    private var observing = false

    public func start(_ onChange: @escaping (Appearance) -> Void) {
        guard !observing else {
            return
        }

        observing = true
        self.onChange = onChange

        appearanceObservation = NSApplication.shared.observe(
            \.effectiveAppearance,
            options: [.new]
        ) { [weak self] _, _ in
            Task { @MainActor [weak self] in
                self?.publishIfChanged()
            }
        }

        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleNotification(_:)),
            name: Self.themeNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleNotification(_:)),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )

        publishIfChanged()
    }

    public func stop() {
        guard observing else {
            return
        }

        appearanceObservation?.invalidate()
        appearanceObservation = nil
        DistributedNotificationCenter.default().removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)

        observing = false
        lastAppearance = nil
        onChange = nil
    }

    @objc
    private func handleNotification(_ notification: Notification) {
        Task { @MainActor [weak self] in
            self?.publishIfChanged()
        }
    }

    private func publishIfChanged() {
        let appearance = Appearance.current

        guard appearance != lastAppearance else {
            return
        }

        lastAppearance = appearance
        onChange?(appearance)
    }
}
