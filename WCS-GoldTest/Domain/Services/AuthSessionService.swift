import Combine
import CryptoKit
import Foundation

@MainActor
final class AuthSessionService: ObservableObject {
    @Published private(set) var currentUser: ManagedUserAccount?
    @Published private(set) var isAuthenticated: Bool = false
    @Published var lastError: String?

    private let repository: AccessPolicyRepository
    private let sessionKey = "wcs.currentUserID"

    init(repository: AccessPolicyRepository) {
        self.repository = repository
    }

    func restoreSession() async {
        guard let idString = UserDefaults.standard.string(forKey: sessionKey),
              let id = UUID(uuidString: idString) else { return }
        do {
            let users = try await repository.fetchUsers()
            currentUser = users.first { $0.id == id && $0.isActive }
            isAuthenticated = currentUser != nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        lastError = nil
        do {
            guard let user = try await repository.verifyPassword(
                email: email.lowercased().trimmingCharacters(in: .whitespaces),
                password: password
            ) else {
                lastError = "Invalid email or password."
                return false
            }
            guard user.isActive else {
                lastError = "Account is suspended. Contact support."
                return false
            }
            currentUser = user
            isAuthenticated = true
            UserDefaults.standard.set(user.id.uuidString, forKey: sessionKey)
            return true
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func signUp(email: String, password: String, displayName: String) async -> Bool {
        lastError = nil
        let normalized = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard normalized.contains("@"), password.count >= 8 else {
            lastError = "Use a valid email and password (8+ characters)."
            return false
        }
        do {
            if try await repository.findUser(email: normalized) != nil {
                lastError = "An account with this email already exists."
                return false
            }
            let channel: DistributionChannel = TestFlightDetector.isTestFlightInstall()
                ? .testFlight
                : AppConfiguration.detectedChannel
            let user = ManagedUserAccount(
                email: normalized,
                displayName: displayName.isEmpty ? normalized : displayName,
                role: .registered,
                plan: .free,
                channel: channel,
                testFlightApproved: false
            )
            try await repository.createUser(user, password: password)
            return await signIn(email: normalized, password: password)
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    static func hashPassword(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
