import Combine
import CoreMotion
import Foundation

@MainActor
final class MotionStabilityService: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published private(set) var stabilityScore: Double = 1.0

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            let magnitude = abs(motion.userAcceleration.x)
                + abs(motion.userAcceleration.y)
                + abs(motion.userAcceleration.z)
            let score = max(0, min(1, 1 - magnitude * 2.2))
            self.stabilityScore = score
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
