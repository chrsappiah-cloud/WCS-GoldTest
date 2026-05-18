import Foundation

protocol ReportRepository: Sendable {
    func fetchAll() async throws -> [ReportRecord]
    func requestReport(for scanSessionID: UUID) async throws -> ReportRecord
}

final class LocalReportRepository: ReportRepository {
    func fetchAll() async throws -> [ReportRecord] { [] }

    func requestReport(for scanSessionID: UUID) async throws -> ReportRecord {
        ReportRecord(
            id: UUID(),
            scanSessionID: scanSessionID,
            createdAt: .now,
            status: .pending,
            pdfURL: nil
        )
    }
}
