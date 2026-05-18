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

    var hasUnlimitedScans: Bool { tier == .premium }
    var hasCloudSync: Bool { tier == .premium }
    var hasPDFReports: Bool { tier == .premium }

    func canStartScan() -> Bool {
        hasUnlimitedScans || scansRemainingThisPeriod > 0
    }

    func consumeScanIfNeeded() {
        guard !hasUnlimitedScans, scansRemainingThisPeriod > 0 else { return }
        scansRemainingThisPeriod -= 1
    }

    // StoreKit 2 integration point — phase 2
    func refreshEntitlements() async {}
}
