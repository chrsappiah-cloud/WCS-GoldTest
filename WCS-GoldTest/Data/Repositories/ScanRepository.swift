import Foundation
import SwiftData

protocol ScanRepository: Sendable {
    func save(session: ScanSession) async throws
    func fetchAll() async throws -> [ScanSession]
    func fetch(id: UUID) async throws -> ScanSession?
}

@MainActor
final class LocalScanRepository: ScanRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(session: ScanSession) async throws {
        let descriptor = FetchDescriptor<PersistedScanSession>(
            predicate: #Predicate { $0.id == session.id }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            existing.update(from: session)
        } else {
            modelContext.insert(PersistedScanSession(session: session))
        }
        if let result = session.result {
            let vaultDescriptor = FetchDescriptor<PersistedVaultItem>(
                predicate: #Predicate { $0.scanSessionID == session.id }
            )
            if try modelContext.fetch(vaultDescriptor).isEmpty {
                modelContext.insert(PersistedVaultItem(session: session, result: result))
            }
        }
        try modelContext.save()
    }

    func fetchAll() async throws -> [ScanSession] {
        let descriptor = FetchDescriptor<PersistedScanSession>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map(\.domainModel)
    }

    func fetch(id: UUID) async throws -> ScanSession? {
        let descriptor = FetchDescriptor<PersistedScanSession>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first?.domainModel
    }
}

// Supabase-backed implementation — phase 2
final class RemoteScanRepository: ScanRepository {
    func save(session: ScanSession) async throws {}
    func fetchAll() async throws -> [ScanSession] { [] }
    func fetch(id: UUID) async throws -> ScanSession? { nil }
}
