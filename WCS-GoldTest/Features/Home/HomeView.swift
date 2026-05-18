import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroHeader
                    deviceStatusCard
                    calibrationCard
                    quickActions
                    subscriptionCard
                }
                .padding()
            }
            .wcsLuxuryScreen()
            .navigationTitle("Home")
            .toolbarTitleDisplayMode(.large)
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "diamond.fill")
                    .foregroundStyle(WCSTheme.diamondGradient)
                Text("WCS Precious Test")
                    .font(.title2.bold())
                    .foregroundStyle(WCSTheme.goldGradient)
            }
            Text("Screen gold & gems with connected precision")
                .font(.subheadline)
                .foregroundStyle(WCSTheme.secondaryText)
            DiamondDivider()
        }
    }

    private var deviceStatusCard: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Device status", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.headline)
                HStack {
                    Circle()
                        .fill(dependencies.bleDeviceManager.isConnected ? .green : .orange)
                        .frame(width: 10, height: 10)
                    Text(dependencies.bleDeviceManager.isConnected ? "Connected" : "Not connected")
                    Spacer()
                    Text("Battery \(dependencies.bleDeviceManager.batteryLevel)%")
                        .foregroundStyle(.secondary)
                }
                Text("Firmware \(dependencies.bleDeviceManager.firmwareVersion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var calibrationCard: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Last calibration")
                    .font(.headline)
                Text("Not calibrated today")
                    .foregroundStyle(.secondary)
                Text("Calibration required before first scan of the day.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var quickActions: some View {
        VStack(spacing: 12) {
            WCSPrimaryButton("New Gold Scan", systemImage: "dot.radiowaves.left.and.right") {}
            NavigationLink {
                PairingView()
            } label: {
                Label("Pair Device", systemImage: "link")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .tint(WCSTheme.goldMid)

            NavigationLink {
                ReportsView()
            } label: {
                Label("View Reports", systemImage: "doc.richtext")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .tint(WCSTheme.diamondSpark)
        }
    }

    private var subscriptionCard: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Subscription")
                    .font(.headline)
                Text(dependencies.subscriptionService.tier == .premium ? "Premium" : "Free tier")
                if !dependencies.subscriptionService.hasUnlimitedScans {
                    Text("\(dependencies.subscriptionService.scansRemainingThisPeriod) scans remaining this period")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppDependencies())
}
