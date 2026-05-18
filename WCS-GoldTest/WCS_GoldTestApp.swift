import SwiftData
import SwiftUI

@main
struct WCS_GoldTestApp: App {
    @StateObject private var dependencies = AppDependencies()

    init() {
        UITestLaunch.configureForTesting()
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(dependencies)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
