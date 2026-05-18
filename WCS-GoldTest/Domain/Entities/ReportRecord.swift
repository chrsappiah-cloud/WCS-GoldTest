import Foundation

struct ReportRecord: Identifiable, Hashable, Sendable {
    let id: UUID
    let scanSessionID: UUID
    let createdAt: Date
    let status: ReportStatus
    let pdfURL: URL?
}

enum ReportStatus: String, Codable, Sendable {
    case pending
    case ready
    case failed
}
