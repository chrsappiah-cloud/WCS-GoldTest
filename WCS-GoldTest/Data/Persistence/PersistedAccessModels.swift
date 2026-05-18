import Foundation
import SwiftData

@Model
final class PersistedUserAccount {
    @Attribute(.unique) var id: UUID
    var email: String
    var displayName: String
    var roleRaw: String
    var planRaw: String
    var channelRaw: String
    var passwordHash: String
    var isActive: Bool
    var testFlightApproved: Bool
    var featureOverridesData: Data
    var deniedFeaturesData: Data
    var createdAt: Date
    var lastLoginAt: Date?

    init(account: ManagedUserAccount, passwordHash: String) {
        id = account.id
        email = account.email
        displayName = account.displayName
        roleRaw = account.role.rawValue
        planRaw = account.plan.rawValue
        channelRaw = account.channel.rawValue
        self.passwordHash = passwordHash
        isActive = account.isActive
        testFlightApproved = account.testFlightApproved
        featureOverridesData = (try? JSONEncoder().encode(account.featureOverrides.map(\.rawValue))) ?? Data()
        deniedFeaturesData = (try? JSONEncoder().encode(account.deniedFeatures.map(\.rawValue))) ?? Data()
        createdAt = account.createdAt
        lastLoginAt = account.lastLoginAt
    }

    func update(from account: ManagedUserAccount) {
        email = account.email
        displayName = account.displayName
        roleRaw = account.role.rawValue
        planRaw = account.plan.rawValue
        channelRaw = account.channel.rawValue
        isActive = account.isActive
        testFlightApproved = account.testFlightApproved
        featureOverridesData = (try? JSONEncoder().encode(account.featureOverrides.map(\.rawValue))) ?? Data()
        deniedFeaturesData = (try? JSONEncoder().encode(account.deniedFeatures.map(\.rawValue))) ?? Data()
        lastLoginAt = account.lastLoginAt
    }

    var domainModel: ManagedUserAccount {
        let overrides = (try? JSONDecoder().decode([String].self, from: featureOverridesData))?
            .compactMap(AppFeature.init(rawValue:)) ?? []
        let denied = (try? JSONDecoder().decode([String].self, from: deniedFeaturesData))?
            .compactMap(AppFeature.init(rawValue:)) ?? []
        return ManagedUserAccount(
            id: id,
            email: email,
            displayName: displayName,
            role: UserRole(rawValue: roleRaw) ?? .registered,
            plan: SubscriptionPlan(rawValue: planRaw) ?? .free,
            channel: DistributionChannel(rawValue: channelRaw) ?? .appStore,
            isActive: isActive,
            testFlightApproved: testFlightApproved,
            featureOverrides: Set(overrides),
            deniedFeatures: Set(denied),
            createdAt: createdAt,
            lastLoginAt: lastLoginAt
        )
    }
}

@Model
final class PersistedEntitlementPolicy {
    @Attribute(.unique) var id: String
    var planRaw: String
    var channelRaw: String
    var featuresData: Data
    var scanLimitPerPeriod: Int?
    var notes: String?

    init(policy: FeatureEntitlementPolicy) {
        id = "\(policy.plan.rawValue)-\(policy.channel.rawValue)"
        planRaw = policy.plan.rawValue
        channelRaw = policy.channel.rawValue
        featuresData = (try? JSONEncoder().encode(policy.enabledFeatures.map(\.rawValue))) ?? Data()
        scanLimitPerPeriod = policy.scanLimitPerPeriod
        notes = policy.notes
    }

    func update(from policy: FeatureEntitlementPolicy) {
        featuresData = (try? JSONEncoder().encode(policy.enabledFeatures.map(\.rawValue))) ?? Data()
        scanLimitPerPeriod = policy.scanLimitPerPeriod
        notes = policy.notes
    }

    var domainModel: FeatureEntitlementPolicy? {
        guard let plan = SubscriptionPlan(rawValue: planRaw),
              let channel = DistributionChannel(rawValue: channelRaw),
              let rawFeatures = try? JSONDecoder().decode([String].self, from: featuresData) else {
            return nil
        }
        return FeatureEntitlementPolicy(
            plan: plan,
            channel: channel,
            enabledFeatures: Set(rawFeatures.compactMap(AppFeature.init(rawValue:))),
            scanLimitPerPeriod: scanLimitPerPeriod,
            notes: notes
        )
    }
}
