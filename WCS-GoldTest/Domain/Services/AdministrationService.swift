import Combine
import Foundation

@MainActor
final class AdministrationService: ObservableObject {
    @Published private(set) var users: [ManagedUserAccount] = []
    @Published var operationMessage: String?

    private let repository: AccessPolicyRepository
    private let accessControl: AccessControlService
    private let auth: AuthSessionService

    init(
        repository: AccessPolicyRepository,
        accessControl: AccessControlService,
        auth: AuthSessionService
    ) {
        self.repository = repository
        self.accessControl = accessControl
        self.auth = auth
    }

    var canOpenAdminPanel: Bool {
        auth.currentUser?.role.isAdmin == true
            && accessControl.canAccess(.adminPanel).allowed
    }

    func refresh() async {
        users = (try? await repository.fetchUsers()) ?? []
        await accessControl.reloadPolicies()
    }

    func updateUser(_ user: ManagedUserAccount) async {
        do {
            try await repository.save(user: user)
            operationMessage = "Updated \(user.email)"
            await refresh()
        } catch {
            operationMessage = error.localizedDescription
        }
    }

    func setTestFlightApproval(userID: UUID, approved: Bool) async {
        guard var user = users.first(where: { $0.id == userID }) else { return }
        user.testFlightApproved = approved
        user.channel = .testFlight
        user.plan = approved ? .testFlightBeta : .free
        user.role = approved ? .testFlightTester : .registered
        await updateUser(user)
    }

    func setRole(userID: UUID, role: UserRole) async {
        guard var user = users.first(where: { $0.id == userID }) else { return }
        user.role = role
        if role == .administrator {
            user.featureOverrides.insert(.adminPanel)
        }
        await updateUser(user)
    }

    func setPlan(userID: UUID, plan: SubscriptionPlan) async {
        guard var user = users.first(where: { $0.id == userID }) else { return }
        user.plan = plan
        if plan == .premiumMonthly || plan == .premiumAnnual {
            user.role = .subscriber
        }
        await updateUser(user)
    }

    func toggleFeatureOverride(userID: UUID, feature: AppFeature, grant: Bool) async {
        guard var user = users.first(where: { $0.id == userID }) else { return }
        if grant {
            user.featureOverrides.insert(feature)
            user.deniedFeatures.remove(feature)
        } else {
            user.featureOverrides.remove(feature)
        }
        await updateUser(user)
    }

    func toggleFeatureDenial(userID: UUID, feature: AppFeature, deny: Bool) async {
        guard var user = users.first(where: { $0.id == userID }) else { return }
        if deny {
            user.deniedFeatures.insert(feature)
            user.featureOverrides.remove(feature)
        } else {
            user.deniedFeatures.remove(feature)
        }
        await updateUser(user)
    }

    func suspendUser(userID: UUID) async {
        guard var user = users.first(where: { $0.id == userID }) else { return }
        user.isActive = false
        await updateUser(user)
    }

    func activateUser(userID: UUID) async {
        guard var user = users.first(where: { $0.id == userID }) else { return }
        user.isActive = true
        await updateUser(user)
    }

    func savePolicy(_ policy: FeatureEntitlementPolicy) async {
        do {
            try await repository.save(policy: policy)
            operationMessage = "Saved policy: \(policy.plan.displayName) · \(policy.channel.displayName)"
            await accessControl.reloadPolicies()
        } catch {
            operationMessage = error.localizedDescription
        }
    }

    func policy(for plan: SubscriptionPlan, channel: DistributionChannel) -> FeatureEntitlementPolicy? {
        accessControl.policies.first { $0.plan == plan && $0.channel == channel }
    }
}
