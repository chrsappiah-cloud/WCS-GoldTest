import SwiftData
import Testing
@testable import WCS_GoldTest

@MainActor
struct AccessControlServiceTests {
    @Test func adminCanAccessAdminPanel() async throws {
        let container = try ModelContainer(
            for: PersistedUserAccount.self, PersistedEntitlementPolicy.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repo = LocalAccessPolicyRepository(modelContext: container.mainContext)
        try repo.seedIfNeeded()
        let auth = AuthSessionService(repository: repo)
        let access = AccessControlService(auth: auth, repository: repo)
        await access.reloadPolicies()
        _ = await auth.signIn(email: "admin@wcsgold.test", password: "WCSAdmin2026!")
        let decision = access.canAccess(.adminPanel)
        #expect(decision.allowed)
    }

    @Test func guestCannotAccessPdfReports() async throws {
        let container = try ModelContainer(
            for: PersistedUserAccount.self, PersistedEntitlementPolicy.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repo = LocalAccessPolicyRepository(modelContext: container.mainContext)
        try repo.seedIfNeeded()
        let auth = AuthSessionService(repository: repo)
        let access = AccessControlService(auth: auth, repository: repo)
        await access.reloadPolicies()
        let decision = access.canAccess(.pdfReports)
        #expect(!decision.allowed)
    }
}
