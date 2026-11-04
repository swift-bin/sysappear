import Foundation

public enum Appearance: String, Sendable {
    case light
    case dark

    public static var current: Appearance {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = ["read", "-g", "AppleInterfaceStyle"]
        process.standardError = FileHandle.nullDevice

        let output = Pipe()
        process.standardOutput = output

        do {
            try process.run()
            let data = output.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                return .light
            }

            let value = String(decoding: data, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return value.caseInsensitiveCompare("Dark") == .orderedSame ? .dark : .light
        } catch {
            return .light
        }
    }
}
