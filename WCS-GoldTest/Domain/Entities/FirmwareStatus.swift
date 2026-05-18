import Foundation

enum FirmwareActivationState: String, Sendable {
    case inactive
    case activating
    case active
    case failed

    var displayName: String {
        switch self {
        case .inactive: "Not activated"
        case .activating: "Activating…"
        case .active: "Active"
        case .failed: "Failed"
        }
    }
}

struct FirmwareInfo: Sendable, Equatable {
    var version: String
    var build: String
    var channel: String
    var activatedAt: Date?

    static let simulatorDefault = FirmwareInfo(
        version: "2.1.0",
        build: "21048",
        channel: "beta-sim",
        activatedAt: nil
    )
}
