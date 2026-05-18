import Foundation
import SwiftData
@testable import WCS_GoldTest

@MainActor
enum TestModelContainer {
    static func make() throws -> ModelContainer {
        let schema = Schema([PersistedUserAccount.self, PersistedEntitlementPolicy.self])
        let config = ModelConfiguration(
            "UnitTest_\(UUID().uuidString)",
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: config)
    }
}
