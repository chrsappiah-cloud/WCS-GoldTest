import SwiftUI

struct AdminUsersView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var selectedUser: ManagedUserAccount?

    var body: some View {
        List {
            ForEach(dependencies.administration.users) { user in
                Button {
                    selectedUser = user
                } label: {
                    AdminUserRow(user: user)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Users")
        .sheet(item: $selectedUser) { user in
            AdminUserDetailSheet(user: user)
                .environmentObject(dependencies)
        }
        .refreshable {
            await dependencies.administration.refresh()
        }
    }
}

struct AdminUserRow: View {
    let user: ManagedUserAccount

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(user.displayName)
                    .font(.headline)
                    .foregroundStyle(WCSTheme.primaryText)
                if !user.isActive {
                    Text("Suspended")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.red.opacity(0.2), in: Capsule())
                }
                Spacer()
                if user.testFlightApproved {
                    Image(systemName: "airplane.circle.fill")
                        .foregroundStyle(WCSTheme.diamondSpark)
                }
            }
            Text(user.email)
                .font(.caption)
                .foregroundStyle(WCSTheme.secondaryText)
            Text("\(user.role.displayName) · \(user.plan.displayName)")
                .font(.caption2)
                .foregroundStyle(WCSTheme.secondaryText)
        }
        .padding(.vertical, 4)
    }
}

struct AdminUserDetailSheet: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss
    @State private var user: ManagedUserAccount

    init(user: ManagedUserAccount) {
        _user = State(initialValue: user)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    TextField("Display name", text: $user.displayName)
                    Text(user.email)
                        .foregroundStyle(.secondary)
                }

                Section("Access") {
                    Picker("Role", selection: $user.role) {
                        ForEach(UserRole.allCases) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    Picker("Plan", selection: $user.plan) {
                        ForEach(SubscriptionPlan.allCases) { plan in
                            Text(plan.displayName).tag(plan)
                        }
                    }
                    Picker("Channel", selection: $user.channel) {
                        ForEach(DistributionChannel.allCases) { ch in
                            Text(ch.displayName).tag(ch)
                        }
                    }
                    Toggle("TestFlight approved", isOn: $user.testFlightApproved)
                    Toggle("Account active", isOn: $user.isActive)
                }

                Section("Feature overrides") {
                    ForEach(AppFeature.allCases) { feature in
                        HStack {
                            Text(feature.displayName)
                            Spacer()
                            if user.featureOverrides.contains(feature) {
                                Text("Granted")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                            if user.deniedFeatures.contains(feature) {
                                Text("Denied")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button("Grant") {
                                Task {
                                    await dependencies.administration.toggleFeatureOverride(
                                        userID: user.id,
                                        feature: feature,
                                        grant: true
                                    )
                                    reloadUser()
                                }
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Deny", role: .destructive) {
                                Task {
                                    await dependencies.administration.toggleFeatureDenial(
                                        userID: user.id,
                                        feature: feature,
                                        deny: true
                                    )
                                    reloadUser()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit user")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await dependencies.administration.updateUser(user)
                            dependencies.subscriptionService.syncFromAccess()
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private func reloadUser() {
        if let updated = dependencies.administration.users.first(where: { $0.id == user.id }) {
            user = updated
        }
    }
}
