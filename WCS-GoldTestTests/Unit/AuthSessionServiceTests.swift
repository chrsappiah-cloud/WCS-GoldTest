import SwiftData
import Testing
@testable import WCS_GoldTest

#if targetEnvironment(simulator)
@MainActor
struct AuthSessionServiceTests {
    @Test func signInWithValidCredentials() async throws {
        let container = try TestModelContainer.make()
        let repo = LocalAccessPolicyRepository(modelContext: container.mainContext)
        try repo.seedIfNeeded()
        let auth = AuthSessionService(repository: repo)
        let ok = await auth.signIn(email: "admin@wcsgold.test", password: "WCSAdmin2026!")
        #expect(ok)
        #expect(auth.isAuthenticated)
        #expect(auth.currentUser?.role == .administrator)
    }

    @Test func signInRejectsInvalidPassword() async throws {
        let container = try TestModelContainer.make()
        let repo = LocalAccessPolicyRepository(modelContext: container.mainContext)
        try repo.seedIfNeeded()
        let auth = AuthSessionService(repository: repo)
        let ok = await auth.signIn(email: "admin@wcsgold.test", password: "wrong")
        #expect(!ok)
        #expect(!auth.isAuthenticated)
    }
}
#endif
