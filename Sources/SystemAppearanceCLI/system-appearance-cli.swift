import AppKit
import Arguments
import Foundation
import SystemAppearance

@main
enum SystemAppearanceCLI {
    @MainActor
    static func main() {
        let application = NSApplication.shared
        _ = application.setActivationPolicy(.accessory)

        Task {
            await AppearanceCommand.main()
        }

        application.run()
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
        emit(Appearance.current)
    }
}

private enum WatchCommand: RunnableArgumentCommand {
    static let name = "watch"

    static func run(_ invocation: ParsedInvocation) async throws {
        let observer = await MainActor.run { () -> AppearanceObserver in
            let observer = AppearanceObserver()
            observer.start(emit)
            return observer
        }

        let (stream, continuation) = AsyncStream<Void>.makeStream()
        var iterator = stream.makeAsyncIterator()
        _ = await iterator.next()
        continuation.finish()
        await observer.stop()
    }
}

private func emit(_ appearance: Appearance) {
    FileHandle.standardOutput.write(
        Data((appearance.rawValue + "\n").utf8)
    )
}
