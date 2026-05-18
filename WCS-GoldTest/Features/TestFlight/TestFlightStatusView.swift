import SwiftUI

struct TestFlightStatusView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        List {
            Section {
                if dependencies.testFlight.isTestFlightBuild {
                    Label("You are on a TestFlight beta build", systemImage: "airplane.circle.fill")
                        .foregroundStyle(WCSTheme.goldMid)
                } else if TestFlightService.isDebugBuild {
                    Label("Development build", systemImage: "hammer.fill")
                } else {
                    Label("App Store build", systemImage: "bag.fill")
                }

                LabeledContent("Version", value: dependencies.testFlight.marketingVersion)
                LabeledContent("Build", value: dependencies.testFlight.buildNumber)
                LabeledContent("Bundle ID", value: dependencies.testFlight.bundleIdentifier)
                LabeledContent("Channel", value: AppConfiguration.detectedChannel.displayName)
            } header: {
                Text("Build info")
            }

            Section {
                if let user = dependencies.authSession.currentUser {
                    LabeledContent("TestFlight approved", value: user.testFlightApproved ? "Yes" : "Pending admin approval")
                    LabeledContent("Beta plan", value: user.plan.displayName)
                } else {
                    Text("Sign in to receive TestFlight beta entitlements after admin approval.")
                        .font(.caption)
                        .foregroundStyle(WCSTheme.secondaryText)
                }
            } header: {
                Text("Beta access")
            }

            Section {
                Link(destination: dependencies.testFlight.appStoreConnectTestFlightURL) {
                    Label("App Store Connect TestFlight", systemImage: "link")
                }
                if let link = dependencies.testFlight.testFlightPublicLink,
                   TestFlightConfig.publicInviteCode != "WCSGOLDTEST" {
                    Link(destination: link) {
                        Label("Invite more testers (public link)", systemImage: "person.badge.plus")
                    }
                } else {
                    Text("Set TestFlightConfig.publicInviteCode after creating a public link in App Store Connect.")
                        .font(.caption)
                        .foregroundStyle(WCSTheme.secondaryText)
                }
            } header: {
                Text("Distribution")
            }

            Section {
                Text(LegalCopy.scanDisclaimer)
                    .font(.caption)
                    .foregroundStyle(WCSTheme.secondaryText)
            }
        }
        .scrollContentBackground(.hidden)
        .wcsLuxuryScreen()
        .navigationTitle("TestFlight")
        .onAppear { dependencies.testFlight.refresh() }
    }
}
