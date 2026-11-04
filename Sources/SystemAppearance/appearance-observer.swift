import AppKit
import Foundation

@MainActor
public final class AppearanceObserver: NSObject {
    private static let themeNotifications: [Notification.Name] = [
        Notification.Name("AppleInterfaceThemeChangedNotification"),
        Notification.Name("AppleColorPreferencesChangedNotification"),
        Notification.Name("AppleAquaColorVariantChanged"),
    ]

    private var onChange: ((Appearance) -> Void)?
    private var lastAppearance: Appearance?
    private var observing = false

    private var debugEnabled: Bool {
        ProcessInfo.processInfo.environment["SYSAPPEAR_DEBUG"] == "1"
    }

    public func start(_ onChange: @escaping (Appearance) -> Void) {
        guard !observing else { return }

        observing = true
        self.onChange = onChange

        for name in Self.themeNotifications {
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(handleThemeNotification(_:)),
                name: name,
                object: nil,
                suspensionBehavior: .deliverImmediately
            )
        }

        if debugEnabled {
            log("subscribed to system theme notifications")
        }
        publishIfChanged()
    }

    public func stop() {
        guard observing else { return }

        observing = false
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(refreshAfterNotification),
            object: nil
        )
        DistributedNotificationCenter.default().removeObserver(self)
        onChange = nil
        lastAppearance = nil
    }

    @objc
    private func handleThemeNotification(_ notification: Notification) {
        if debugEnabled {
            log("received: \(notification.name.rawValue)")
        }

        publishIfChanged()
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(refreshAfterNotification),
            object: nil
        )
        perform(
            #selector(refreshAfterNotification),
            with: nil,
            afterDelay: 0.25,
            inModes: [.common]
        )
    }

    @objc
    private func refreshAfterNotification() {
        publishIfChanged()
    }

    private func publishIfChanged() {
        guard observing else { return }

        let appearance = Appearance.current
        if debugEnabled {
            log("observed appearance: \(appearance.rawValue)")
        }
        guard appearance != lastAppearance else { return }
        lastAppearance = appearance
        onChange?(appearance)
    }

    private func log(_ message: String) {
        FileHandle.standardError.write(Data(("sysappear: " + message + "\n").utf8))
    }
}
