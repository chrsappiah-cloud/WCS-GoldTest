import Foundation

struct AccuracyFusionEngine: Sendable {
    func fuse(basePurity: Double, baseKarat: Double, evidence: EvidenceBundle) -> FusedAssessment {
        let weights = [0.40, 0.15, 0.15, 0.10, 0.10, 0.10]
        let scores = [
            evidence.probeSignalScore,
            evidence.motionStabilityScore,
            evidence.calibrationFreshnessScore,
            evidence.imageSupportScore,
            evidence.repeatedScanAgreementScore,
            evidence.cloudConsensusScore,
        ]
        let confidence = zip(weights, scores).reduce(0.0) { $0 + ($1.0 * $1.1) }

        var warnings: [String] = []
        if evidence.motionStabilityScore < 0.55 {
            warnings.append("Movement detected during scan")
        }
        if evidence.calibrationFreshnessScore < 0.50 {
            warnings.append("Calibration may be stale")
        }
        if evidence.repeatedScanAgreementScore < 0.60 {
            warnings.append("Repeated scans do not agree")
        }

        return FusedAssessment(
            estimatedPurityPercent: basePurity,
            estimatedKarat: baseKarat,
            confidence: confidence,
            warnings: warnings
        )
    }
}
