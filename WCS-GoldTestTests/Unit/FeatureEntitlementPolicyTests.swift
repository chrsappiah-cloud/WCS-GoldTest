import Testing
@testable import WCS_GoldTest

struct FeatureEntitlementPolicyTests {
    @Test func defaultPoliciesIncludeTestFlightBeta() {
        let policies = FeatureEntitlementPolicy.defaultPolicies()
        let beta = policies.first { $0.plan == .testFlightBeta && $0.channel == .testFlight }
        #expect(beta != nil)
        #expect(beta?.enabledFeatures.contains(.goldScan) == true)
        #expect(beta?.scanLimitPerPeriod == nil)
    }

    @Test func appStoreConnectAppIDMatches() {
        #expect(AppStoreConnect.appID == "6770415355")
    }
}
