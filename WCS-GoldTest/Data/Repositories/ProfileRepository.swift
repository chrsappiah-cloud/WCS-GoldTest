import Foundation

struct UserProfile: Sendable {
    let id: UUID
    let fullName: String?
    let createdAt: Date
}

protocol ProfileRepository: Sendable {
    func currentProfile() async throws -> UserProfile?
    func signIn(email: String, password: String) async throws
    func signOut() async throws
}

final class LocalProfileRepository: ProfileRepository {
    func currentProfile() async throws -> UserProfile? { nil }
    func signIn(email: String, password: String) async throws {}
    func signOut() async throws {}
}
