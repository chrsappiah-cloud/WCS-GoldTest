import CloudKit
import Foundation

/// Private CloudKit summaries — phase 2 dual-sync with Supabase.
final class CloudKitSyncCoordinator: Sendable {
    private let privateDB = CKContainer.default().privateCloudDatabase

    func saveScanSummary(id: UUID, classification: String, confidence: Double) async throws {
        let record = CKRecord(
            recordType: "ScanSummary",
            recordID: CKRecord.ID(recordName: id.uuidString)
        )
        record["classification"] = classification as CKRecordValue
        record["confidence"] = confidence as CKRecordValue
        try await privateDB.save(record)
    }
}
