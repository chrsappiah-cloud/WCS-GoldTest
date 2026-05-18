import Foundation
import SwiftData

@Model
final class PersistedScanSession {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var materialRaw: String
    var deviceId: String
    var rawSignalsData: Data
    var temperatureCelsius: Double?
    var resultClassification: String?
    var estimatedPurityPercent: Double?
    var estimatedKarat: Double?
    var confidence: Double?
    var warningsData: Data?
    var notes: String?

    init(session: ScanSession) {
        id = session.id
        createdAt = session.createdAt
        materialRaw = session.material.rawValue
        deviceId = session.deviceId
        rawSignalsData = (try? JSONEncoder().encode(session.rawSignals)) ?? Data()
        temperatureCelsius = session.temperatureCelsius
        notes = session.notes
        if let result = session.result {
            resultClassification = result.classification
            estimatedPurityPercent = result.estimatedPurityPercent
            estimatedKarat = result.estimatedKarat
            confidence = result.confidence
            warningsData = try? JSONEncoder().encode(result.warnings)
        }
    }

    func update(from session: ScanSession) {
        createdAt = session.createdAt
        materialRaw = session.material.rawValue
        deviceId = session.deviceId
        rawSignalsData = (try? JSONEncoder().encode(session.rawSignals)) ?? Data()
        temperatureCelsius = session.temperatureCelsius
        notes = session.notes
        if let result = session.result {
            resultClassification = result.classification
            estimatedPurityPercent = result.estimatedPurityPercent
            estimatedKarat = result.estimatedKarat
            confidence = result.confidence
            warningsData = try? JSONEncoder().encode(result.warnings)
        }
    }

    var domainModel: ScanSession {
        let signals = (try? JSONDecoder().decode([Double].self, from: rawSignalsData)) ?? []
        let warnings = warningsData.flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []
        let material = MaterialType(rawValue: materialRaw) ?? .gold
        let result: ScanResult? = resultClassification.map {
            ScanResult(
                estimatedPurityPercent: estimatedPurityPercent,
                estimatedKarat: estimatedKarat,
                classification: $0,
                confidence: confidence ?? 0,
                warnings: warnings
            )
        }
        return ScanSession(
            id: id,
            createdAt: createdAt,
            material: material,
            deviceId: deviceId,
            rawSignals: signals,
            temperatureCelsius: temperatureCelsius,
            result: result,
            notes: notes
        )
    }
}

@Model
final class PersistedVaultItem {
    @Attribute(.unique) var id: UUID
    var scanSessionID: UUID
    var materialRaw: String
    var title: String
    var latestPurityPercent: Double?
    var latestKarat: Double?
    var confidence: Double
    var createdAt: Date

    init(session: ScanSession, result: ScanResult) {
        id = UUID()
        scanSessionID = session.id
        materialRaw = session.material.rawValue
        title = result.classification
        latestPurityPercent = result.estimatedPurityPercent
        latestKarat = result.estimatedKarat
        confidence = result.confidence
        createdAt = session.createdAt
    }

    var domainModel: VaultItem {
        VaultItem(
            id: id,
            scanSessionID: scanSessionID,
            material: MaterialType(rawValue: materialRaw) ?? .gold,
            thumbnailSystemImage: "circle.hexagongrid.fill",
            latestPurityPercent: latestPurityPercent,
            latestKarat: latestKarat,
            confidence: confidence,
            createdAt: createdAt,
            title: title
        )
    }
}
