import Testing
@testable import WCS_GoldTest

struct TestFlightServiceTests {
    @Test func appStoreConnectID() {
        #expect(AppStoreConnect.appID == "6770415355")
    }

    @Test func debugBuildIsNotTestFlight() {
        #if DEBUG
        #expect(TestFlightService.isDebugBuild)
        #endif
    }
}
