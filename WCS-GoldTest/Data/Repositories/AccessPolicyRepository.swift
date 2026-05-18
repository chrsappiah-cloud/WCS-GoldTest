import Foundation
import SwiftData

protocol AccessPolicyRepository: Sendable {
    func fetchPolicies() async throws -> [FeatureEntitlementPolicy]
    func save(policy: FeatureEntitlementPolicy) async throws
    func fetchUsers() async throws -> [ManagedUserAccount]
    func save(user: ManagedUserAccount) async throws
    func findUser(email: String) async throws -> ManagedUserAccount?
    func createUser(_ account: ManagedUserAccount, password: String) async throws
    func verifyPassword(email: String, password: String) async throws -> ManagedUserAccount?
}

@MainActor
final class LocalAccessPolicyRepository: AccessPolicyRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func seedIfNeeded() throws {
        let policyDescriptor = FetchDescriptor<PersistedEntitlementPolicy>()
        if try modelContext.fetch(policyDescriptor).isEmpty {
            for policy in FeatureEntitlementPolicy.defaultPolicies() {
                modelContext.insert(PersistedEntitlementPolicy(policy: policy))
            }
        }

        let userDescriptor = FetchDescriptor<PersistedUserAccount>()
        if try modelContext.fetch(userDescriptor).isEmpty {
            let admin = ManagedUserAccount(
                email: "admin@wcsgold.test",
                displayName: "WCS Administrator",
                role: .administrator,
                plan: .premiumAnnual,
                channel: .internalQA,
                testFlightApproved: true,
                featureOverrides: [.adminPanel]
            )
            modelContext.insert(PersistedUserAccount(
                account: admin,
                passwordHash: AuthSessionService.hashPassword("WCSAdmin2026!")
            ))

            let tester = ManagedUserAccount(
                email: "testflight@wcsgold.test",
                displayName: "TestFlight Tester",
                role: .testFlightTester,
                plan: .testFlightBeta,
                channel: .testFlight,
                testFlightApproved: true
            )
            modelContext.insert(PersistedUserAccount(
                account: tester,
                passwordHash: AuthSessionService.hashPassword("TestFlight2026!")
            ))
        }
        try modelContext.save()
    }

    func fetchPolicies() async throws -> [FeatureEntitlementPolicy] {
        try modelContext.fetch(FetchDescriptor<PersistedEntitlementPolicy>())
            .compactMap(\.domainModel)
    }

    func save(policy: FeatureEntitlementPolicy) async throws {
        let id = "\(policy.plan.rawValue)-\(policy.channel.rawValue)"
        let descriptor = FetchDescriptor<PersistedEntitlementPolicy>(
            predicate: #Predicate { $0.id == id }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            existing.update(from: policy)
        } else {
            modelContext.insert(PersistedEntitlementPolicy(policy: policy))
        }
        try modelContext.save()
    }

    func fetchUsers() async throws -> [ManagedUserAccount] {
        try modelContext.fetch(FetchDescriptor<PersistedUserAccount>())
            .map(\.domainModel)
            .sorted { $0.email < $1.email }
    }

    func save(user: ManagedUserAccount) async throws {
        let descriptor = FetchDescriptor<PersistedUserAccount>(
            predicate: #Predicate { $0.id == user.id }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            existing.update(from: user)
        }
        try modelContext.save()
    }

    func findUser(email: String) async throws -> ManagedUserAccount? {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespaces)
        let descriptor = FetchDescriptor<PersistedUserAccount>(
            predicate: #Predicate { $0.email == normalized }
        )
        return try modelContext.fetch(descriptor).first?.domainModel
    }

    func createUser(_ account: ManagedUserAccount, password: String) async throws {
        let normalized = account.email.lowercased().trimmingCharacters(in: .whitespaces)
        var user = account
        user.email = normalized
        modelContext.insert(PersistedUserAccount(
            account: user,
            passwordHash: AuthSessionService.hashPassword(password)
        ))
        try modelContext.save()
    }

    func verifyPassword(email: String, password: String) async throws -> ManagedUserAccount? {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespaces)
        let hash = AuthSessionService.hashPassword(password)
        let descriptor = FetchDescriptor<PersistedUserAccount>(
            predicate: #Predicate { $0.email == normalized && $0.passwordHash == hash }
        )
        guard let record = try modelContext.fetch(descriptor).first else { return nil }
        var user = record.domainModel
        user.lastLoginAt = .now
        record.lastLoginAt = .now
        try modelContext.save()
        return user
    }
}
