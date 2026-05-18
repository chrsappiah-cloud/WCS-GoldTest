import Foundation

struct VaultItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let scanSessionID: UUID
    let material: MaterialType
    let thumbnailSystemImage: String
    let latestPurityPercent: Double?
    let latestKarat: Double?
    let confidence: Double
    let createdAt: Date
    let title: String
}
