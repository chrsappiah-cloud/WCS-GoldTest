import Foundation

struct GoldRulesEngine: Sendable {
    /// Placeholder thresholds — replace with calibration-derived mappings before release.
    func evaluate(signal: [Double]) -> ScanResult {
        let avg = signal.isEmpty ? 0 : signal.reduce(0, +) / Double(signal.count)

        let karat: Double
        let purity: Double
        let label: String

        switch avg {
        case 0..<0.18:
            karat = 10
            purity = 41.7
            label = "Low-karat gold alloy"
        case 0.18..<0.32:
            karat = 14
            purity = 58.5
            label = "14K range"
        case 0.32..<0.48:
            karat = 18
            purity = 75.0
            label = "18K range"
        case 0.48..<0.70:
            karat = 22
            purity = 91.6
            label = "22K range"
        default:
            karat = 24
            purity = 99.9
            label = "24K or near-pure gold"
        }

        return ScanResult(
            estimatedPurityPercent: purity,
            estimatedKarat: karat,
            classification: label,
            confidence: min(0.99, max(0.55, avg)),
            warnings: [],
            provenance: .bleOnly
        )
    }
}
