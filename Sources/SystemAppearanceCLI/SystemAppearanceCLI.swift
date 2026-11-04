import AppKit
import Arguments
import Foundation
import SystemAppearance

@main
enum SystemAppearanceCLI {
    static func main() async {
        await AppearanceCommand.main()
    }
}

private enum AppearanceCommand: ArgumentCommand {
    typealias DefaultChild = GetCommand

    static let name = "sysappear"
    static var defaultChild: GetCommand.Type { GetCommand.self }
    static var children: [ArgumentCommandType] {
        [
            GetCommand.self,
            WatchCommand.self,
        ]
    }
}

private enum GetCommand: RunnableArgumentCommand {
    static let name = "get"

    static func run(_ invocation: ParsedInvocation) async throws {
        let appearance = await MainActor.run {
            let application = NSApplication.shared
            _ = application.setActivationPolicy(.prohibited)
            return Appearance.current
        }
        emit(appearance)
    }
}

private enum WatchCommand: RunnableArgumentCommand {
    static let name = "watch"

    static func run(_ invocation: ParsedInvocation) async throws {
        await MainActor.run {
            let application = NSApplication.shared
            _ = application.setActivationPolicy(.prohibited)

            let observer = AppearanceObserver()
            observer.start { appearance in
                emit(appearance)
            }

            withExtendedLifetime(observer) {
                application.run()
            }
        }
    }
}

private func emit(_ appearance: Appearance) {
    FileHandle.standardOutput.write(
        Data((appearance.rawValue + "\n").utf8)
    )
}
