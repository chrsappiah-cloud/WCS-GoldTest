import SwiftData
import SwiftUI

@main
struct WCS_GoldTestApp: App {
    @StateObject private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(dependencies)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
