import Foundation

struct ScanSession: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let createdAt: Date
    let material: MaterialType
    let deviceId: String
    let rawSignals: [Double]
    let temperatureCelsius: Double?
    let result: ScanResult?
    let notes: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        material: MaterialType,
        deviceId: String,
        rawSignals: [Double],
        temperatureCelsius: Double? = nil,
        result: ScanResult? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.material = material
        self.deviceId = deviceId
        self.rawSignals = rawSignals
        self.temperatureCelsius = temperatureCelsius
        self.result = result
        self.notes = notes
    }
}

enum MaterialType: String, Codable, CaseIterable, Identifiable, Sendable {
    case gold
    case diamond
    case gemstone

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gold: "Gold"
        case .diamond: "Diamond"
        case .gemstone: "Gemstone"
        }
    }

    var systemImage: String {
        switch self {
        case .gold: "circle.hexagongrid.fill"
        case .diamond: "diamond.fill"
        case .gemstone: "sparkles"
        }
    }
}

struct ScanResult: Codable, Hashable, Sendable {
    let estimatedPurityPercent: Double?
    let estimatedKarat: Double?
    let classification: String
    let confidence: Double
    let warnings: [String]
    let provenance: ResultProvenance

    init(
        estimatedPurityPercent: Double?,
        estimatedKarat: Double?,
        classification: String,
        confidence: Double,
        warnings: [String],
        provenance: ResultProvenance = .bleOnly
    ) {
        self.estimatedPurityPercent = estimatedPurityPercent
        self.estimatedKarat = estimatedKarat
        self.classification = classification
        self.confidence = confidence
        self.warnings = warnings
        self.provenance = provenance
    }
}

enum ResultProvenance: String, Codable, Sendable {
    case localOnly
    case bleOnly
    case blePlusCloud
    case importedProInstrument
}

enum ScanViewState: Equatable, Sendable {
    case idle
    case checklist
    case scanning
    case completed
    case failed
}
