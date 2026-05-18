import SwiftUI

struct AdminTestFlightView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    private var pendingTesters: [ManagedUserAccount] {
        dependencies.administration.users.filter {
            $0.channel == .testFlight && !$0.testFlightApproved
        }
    }

    private var approvedTesters: [ManagedUserAccount] {
        dependencies.administration.users.filter(\.testFlightApproved)
    }

    var body: some View {
        List {
            Section {
                Link(destination: URL(string: "https://appstoreconnect.apple.com/apps/\(AppStoreConnect.appID)/testflight")!) {
                    Label("Open TestFlight in App Store Connect", systemImage: "link")
                }
                Text("Manage external testers in ASC, then approve accounts here to unlock in-app beta entitlements.")
                    .font(.caption)
                    .foregroundStyle(WCSTheme.secondaryText)
            }

            Section("Pending TestFlight approval") {
                if pendingTesters.isEmpty {
                    Text("No pending requests")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(pendingTesters) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.email)
                                Text(user.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Approve") {
                                Task {
                                    await dependencies.administration.setTestFlightApproval(
                                        userID: user.id,
                                        approved: true
                                    )
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(WCSTheme.goldMid)
                        }
                    }
                }
            }

            Section("Approved testers") {
                ForEach(approvedTesters) { user in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.email)
                            Text("\(user.plan.displayName) · \(user.role.displayName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Revoke") {
                            Task {
                                await dependencies.administration.setTestFlightApproval(
                                    userID: user.id,
                                    approved: false
                                )
                            }
                        }
                        .foregroundStyle(.red)
                    }
                }
            }

            Section("Subscription plan assignment") {
                ForEach(dependencies.administration.users.filter { $0.role != .administrator }) { user in
                    Menu {
                        ForEach(SubscriptionPlan.allCases) { plan in
                            Button(plan.displayName) {
                                Task {
                                    await dependencies.administration.setPlan(userID: user.id, plan: plan)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(user.email)
                            Spacer()
                            Text(user.plan.displayName)
                                .foregroundStyle(WCSTheme.goldMid)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .wcsLuxuryScreen()
        .navigationTitle("TestFlight & Plans")
        .refreshable {
            await dependencies.administration.refresh()
        }
    }
}
