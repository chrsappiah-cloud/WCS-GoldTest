import Foundation
import SwiftData
import Testing
@testable import WCS_GoldTest

#if targetEnvironment(simulator)
@MainActor
struct AdministrationServiceTests {
    private func makeStack() throws -> (
        LocalAccessPolicyRepository,
        AuthSessionService,
        AccessControlService,
        AdministrationService
    ) {
        let container = try TestModelContainer.make()
        let repo = LocalAccessPolicyRepository(modelContext: container.mainContext)
        try repo.seedIfNeeded()
        let auth = AuthSessionService(repository: repo)
        let access = AccessControlService(auth: auth, repository: repo)
        let admin = AdministrationService(repository: repo, accessControl: access, auth: auth)
        return (repo, auth, access, admin)
    }

    @Test func approveTestFlightUpdatesUserPlan() async throws {
        let (_, auth, _, admin) = try makeStack()
        _ = await auth.signIn(email: "admin@wcsgold.test", password: "WCSAdmin2026!")
        await admin.refresh()
        let tester = try #require(admin.users.first { $0.email == "testflight@wcsgold.test" })
        await admin.setTestFlightApproval(userID: tester.id, approved: true)
        await admin.refresh()
        let updated = try #require(admin.users.first { $0.id == tester.id })
        #expect(updated.testFlightApproved)
        #expect(updated.plan == .testFlightBeta)
    }

    @Test func adminPanelRequiresAdministrator() async throws {
        let (_, auth, access, admin) = try makeStack()
        #expect(!admin.canOpenAdminPanel)
        _ = await auth.signIn(email: "admin@wcsgold.test", password: "WCSAdmin2026!")
        await access.reloadPolicies()
        #expect(admin.canOpenAdminPanel)
    }
}
#endif
