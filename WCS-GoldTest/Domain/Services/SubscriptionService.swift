import Combine
import Foundation

enum SubscriptionTier: String, Sendable {
    case free
    case premium
}

@MainActor
final class SubscriptionService: ObservableObject {
    @Published private(set) var tier: SubscriptionTier = .free
    @Published private(set) var scansRemainingThisPeriod: Int = 5

    private var accessControl: AccessControlService?

    func bind(accessControl: AccessControlService) {
        self.accessControl = accessControl
        syncFromAccess()
    }

    func syncFromAccess() {
        guard let access = accessControl else { return }
        let hasPremiumFeatures = access.canAccess(.pdfReports).allowed
            && access.canAccess(.cloudSync).allowed
        tier = hasPremiumFeatures ? .premium : .free

        if let user = access.auth.currentUser,
           let policy = access.policies.first(where: {
               $0.plan == user.plan && $0.channel == user.channel
           }),
           let limit = policy.scanLimitPerPeriod {
            scansRemainingThisPeriod = max(0, limit - access.scansUsedThisPeriod)
        } else if tier == .premium {
            scansRemainingThisPeriod = 999
        } else {
            scansRemainingThisPeriod = max(0, 5 - access.scansUsedThisPeriod)
        }
    }

    var hasUnlimitedScans: Bool {
        guard let access = accessControl else { return false }
        return access.canStartScan(material: .gold).allowed
            && access.policies.contains { policy in
                policy.scanLimitPerPeriod == nil
                    && policy.enabledFeatures.contains(.goldScan)
            }
    }

    var hasCloudSync: Bool { accessControl?.canAccess(.cloudSync).allowed ?? false }
    var hasPDFReports: Bool { accessControl?.canAccess(.pdfReports).allowed ?? false }

    func canStartScan() -> Bool {
        accessControl?.canStartScan(material: .gold).allowed
            ?? (hasUnlimitedScans || scansRemainingThisPeriod > 0)
    }

    func consumeScanIfNeeded() {
        accessControl?.recordScanConsumed()
        syncFromAccess()
    }

    func refreshEntitlements() async {
        await accessControl?.reloadPolicies()
        syncFromAccess()
    }
}
