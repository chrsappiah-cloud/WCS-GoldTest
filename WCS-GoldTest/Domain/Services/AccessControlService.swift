import Combine
import Foundation

@MainActor
final class AccessControlService: ObservableObject {
    @Published private(set) var policies: [FeatureEntitlementPolicy] = []
    @Published private(set) var scansUsedThisPeriod: Int = 0

    let auth: AuthSessionService
    private let repository: AccessPolicyRepository

    init(auth: AuthSessionService, repository: AccessPolicyRepository) {
        self.auth = auth
        self.repository = repository
    }

    func reloadPolicies() async {
        policies = (try? await repository.fetchPolicies()) ?? FeatureEntitlementPolicy.defaultPolicies()
    }

    func canAccess(_ feature: AppFeature) -> AccessDecision {
        guard let user = auth.currentUser else {
            return AccessDecision(
                allowed: feature == .goldScan,
                feature: feature,
                reason: "Sign in to unlock full access."
            )
        }
        guard user.isActive else {
            return AccessDecision(allowed: false, feature: feature, reason: "Account suspended.")
        }

        if user.deniedFeatures.contains(feature) {
            return AccessDecision(allowed: false, feature: feature, reason: "Blocked by administrator.")
        }
        if user.featureOverrides.contains(feature) {
            return AccessDecision(allowed: true, feature: feature, reason: "Granted by administrator.")
        }
        if user.role.isAdmin, feature == .adminPanel {
            return AccessDecision(allowed: true, feature: feature, reason: "Administrator access.")
        }

        let effectivePlan = effectivePlan(for: user)
        let policy = policies.first {
            $0.plan == effectivePlan && $0.channel == user.channel
        } ?? policies.first { $0.plan == effectivePlan }

        guard let policy else {
            return AccessDecision(allowed: false, feature: feature, reason: "No entitlement policy configured.")
        }

        if policy.enabledFeatures.contains(feature) {
            return AccessDecision(allowed: true, feature: feature, reason: policy.notes ?? "Included in plan.")
        }
        return AccessDecision(
            allowed: false,
            feature: feature,
            reason: "Upgrade or request TestFlight approval for \(feature.displayName)."
        )
    }

    func canStartScan(material: MaterialType) -> AccessDecision {
        let feature: AppFeature = switch material {
        case .gold: .goldScan
        case .diamond: .diamondScan
        case .gemstone: .gemstoneScan
        }
        let base = canAccess(feature)
        guard base.allowed else { return base }

        guard let user = auth.currentUser else { return base }
        let effectivePlan = effectivePlan(for: user)
        let policy = policies.first {
            $0.plan == effectivePlan && $0.channel == user.channel
        }

        if let limit = policy?.scanLimitPerPeriod, scansUsedThisPeriod >= limit {
            return AccessDecision(
                allowed: false,
                feature: feature,
                reason: "Scan limit reached (\(limit) per period). Upgrade or contact admin."
            )
        }
        return base
    }

    func recordScanConsumed() {
        scansUsedThisPeriod += 1
    }

    func enabledFeaturesForCurrentUser() -> [AppFeature] {
        AppFeature.allCases.filter { canAccess($0).allowed }
    }

    private func effectivePlan(for user: ManagedUserAccount) -> SubscriptionPlan {
        if user.role == .administrator { return .premiumAnnual }
        if user.channel == .testFlight, user.testFlightApproved {
            return .testFlightBeta
        }
        if user.role == .subscriber { return user.plan }
        return user.plan
    }
}
