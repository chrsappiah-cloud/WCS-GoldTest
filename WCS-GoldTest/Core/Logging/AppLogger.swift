import Foundation
import os

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "wcs.WCS-GoldTest"

    static let ble = Logger(subsystem: subsystem, category: "BLE")
    static let scan = Logger(subsystem: subsystem, category: "Scan")
    static let sync = Logger(subsystem: subsystem, category: "Sync")
    static let subscription = Logger(subsystem: subsystem, category: "Subscription")
}
