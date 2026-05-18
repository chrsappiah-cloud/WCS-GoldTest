import SwiftUI

/// StoreKit 2 paywall — phase 2.
struct SubscriptionPaywallView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        VStack(spacing: 20) {
            Text("WCS Premium")
                .font(.largeTitle.bold())
            Text("Unlimited scans, cloud sync, PDF reports, and device diagnostics history.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            WCSPrimaryButton("Subscribe", systemImage: "star.fill") {
                Task { await dependencies.subscriptionService.refreshEntitlements() }
            }

            Button("Restore purchases") {
                Task { await dependencies.subscriptionService.refreshEntitlements() }
            }
            .font(.footnote)
        }
        .padding()
        .navigationTitle("Premium")
    }
}
