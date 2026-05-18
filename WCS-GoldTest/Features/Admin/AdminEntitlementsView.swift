import SwiftUI

struct AdminEntitlementsView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var selectedPlan: SubscriptionPlan = .free
    @State private var selectedChannel: DistributionChannel = .testFlight
    @State private var enabledFeatures: Set<AppFeature> = []
    @State private var scanLimit: String = "5"
    @State private var unlimitedScans = false

    var body: some View {
        Form {
            Section("Policy target") {
                Picker("Subscription plan", selection: $selectedPlan) {
                    ForEach(SubscriptionPlan.allCases) { plan in
                        Text(plan.displayName).tag(plan)
                    }
                }
                Picker("Distribution channel", selection: $selectedChannel) {
                    ForEach(DistributionChannel.allCases) { channel in
                        Text(channel.displayName).tag(channel)
                    }
                }
            }

            Section("Functions enabled") {
                ForEach(AppFeature.allCases) { feature in
                    Toggle(feature.displayName, isOn: Binding(
                        get: { enabledFeatures.contains(feature) },
                        set: { on in
                            if on { enabledFeatures.insert(feature) }
                            else { enabledFeatures.remove(feature) }
                        }
                    ))
                }
            }

            Section("Scan limits") {
                Toggle("Unlimited scans", isOn: $unlimitedScans)
                if !unlimitedScans {
                    TextField("Scans per period", text: $scanLimit)
                        .keyboardType(.numberPad)
                }
            }

            Section {
                WCSPrimaryButton("Save entitlement policy", systemImage: "square.and.arrow.down") {
                    Task {
                        let limit = unlimitedScans ? nil : Int(scanLimit)
                        let policy = FeatureEntitlementPolicy(
                            plan: selectedPlan,
                            channel: selectedChannel,
                            enabledFeatures: enabledFeatures,
                            scanLimitPerPeriod: limit,
                            notes: "Updated by admin · ASC \(AppStoreConnect.appID)"
                        )
                        await dependencies.administration.savePolicy(policy)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .wcsLuxuryScreen()
        .navigationTitle("Entitlements")
        .onChange(of: selectedPlan) { loadPolicy() }
        .onChange(of: selectedChannel) { loadPolicy() }
        .onAppear { loadPolicy() }
    }

    private func loadPolicy() {
        if let policy = dependencies.administration.policy(for: selectedPlan, channel: selectedChannel) {
            enabledFeatures = policy.enabledFeatures
            if let limit = policy.scanLimitPerPeriod {
                unlimitedScans = false
                scanLimit = String(limit)
            } else {
                unlimitedScans = true
            }
        } else {
            enabledFeatures = [.goldScan]
            unlimitedScans = false
            scanLimit = "5"
        }
    }
}
