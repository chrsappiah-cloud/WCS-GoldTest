import Testing
@testable import WCS_GoldTest

struct AccuracyFusionEngineTests {
    @Test func lowMotionStabilityAddsWarning() {
        let engine = AccuracyFusionEngine()
        let assessment = engine.fuse(
            basePurity: 75,
            baseKarat: 18,
            evidence: EvidenceBundle(
                probeSignalScore: 0.8,
                motionStabilityScore: 0.3,
                calibrationFreshnessScore: 0.9,
                imageSupportScore: 0.5,
                repeatedScanAgreementScore: 0.8,
                cloudConsensusScore: 0.5
            )
        )
        #expect(assessment.warnings.contains("Movement detected during scan"))
    }
}
