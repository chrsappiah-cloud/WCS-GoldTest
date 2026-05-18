import Testing
@testable import WCS_GoldTest

struct GoldRulesEngineTests {
    @Test func lowSignalMapsToTenK() {
        let engine = GoldRulesEngine()
        let result = engine.evaluate(signal: [0.1, 0.12, 0.11])
        #expect(result.estimatedKarat == 10)
        #expect(result.classification.contains("Low-karat"))
    }

    @Test func midSignalMapsToEighteenK() {
        let engine = GoldRulesEngine()
        let result = engine.evaluate(signal: [0.35, 0.38, 0.36])
        #expect(result.estimatedKarat == 18)
    }

    @Test func highSignalMapsToTwentyFourK() {
        let engine = GoldRulesEngine()
        let result = engine.evaluate(signal: [0.8, 0.85, 0.82])
        #expect(result.estimatedKarat == 24)
    }
}
