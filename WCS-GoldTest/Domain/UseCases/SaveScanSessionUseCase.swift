import Foundation

struct SaveScanSessionUseCase: Sendable {
    private let repository: ScanRepository

    init(repository: ScanRepository) {
        self.repository = repository
    }

    func execute(session: ScanSession) async throws {
        try await repository.save(session: session)
    }
}
