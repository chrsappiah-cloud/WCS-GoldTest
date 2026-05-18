import Foundation

struct EvidenceBundle: Sendable {
    let probeSignalScore: Double
    let motionStabilityScore: Double
    let calibrationFreshnessScore: Double
    let imageSupportScore: Double
    let repeatedScanAgreementScore: Double
    let cloudConsensusScore: Double
}

struct FusedAssessment: Sendable {
    let estimatedPurityPercent: Double
    let estimatedKarat: Double
    let confidence: Double
    let warnings: [String]
}
