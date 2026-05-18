import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        List {
            Section {
                LabeledContent("App Store Connect ID", value: AppStoreConnect.appID)
                LabeledContent("Bundle ID", value: AppStoreConnect.bundleIdentifier)
                LabeledContent("Distribution", value: AppConfiguration.detectedChannel.displayName)
            } header: {
                Text("In-flight build")
            }

            Section("Administration") {
                NavigationLink {
                    AdminUsersView()
                } label: {
                    Label("User access control", systemImage: "person.3.fill")
                }
                NavigationLink {
                    AdminEntitlementsView()
                } label: {
                    Label("Feature entitlements by plan", systemImage: "switch.2")
                }
                NavigationLink {
                    AdminTestFlightView()
                } label: {
                    Label("TestFlight & subscriptions", systemImage: "airplane")
                }
            }

            if let message = dependencies.administration.operationMessage {
                Section {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(WCSTheme.secondaryText)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .wcsLuxuryScreen()
        .navigationTitle("Administration")
        .task {
            await dependencies.administration.refresh()
        }
    }
}
