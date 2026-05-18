import SwiftUI

struct UserAccessView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isRegistering = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if dependencies.authSession.isAuthenticated {
                    signedInPanel
                } else {
                    authForm
                }
                entitlementsPanel
                testFlightPanel
            }
            .padding()
        }
        .navigationTitle("Account & Access")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("User access", systemImage: "person.crop.circle.badge.checkmark")
                .font(.title2.bold())
                .foregroundStyle(WCSTheme.goldGradient)
            Text("App Store Connect · App \(AppStoreConnect.appID)")
                .font(.caption)
                .foregroundStyle(WCSTheme.secondaryText)
            DiamondDivider()
        }
    }

    private var signedInPanel: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 12) {
                if let user = dependencies.authSession.currentUser {
                    Text(user.displayName)
                        .font(.headline)
                    Text(user.email)
                        .foregroundStyle(WCSTheme.secondaryText)
                    LabeledContent("Role", value: user.role.displayName)
                    LabeledContent("Plan", value: user.plan.displayName)
                    LabeledContent("Channel", value: user.channel.displayName)
                    LabeledContent("TestFlight", value: user.testFlightApproved ? "Approved" : "Pending")
                }
                Button("Sign out", role: .destructive) {
                    dependencies.authSession.signOut()
                    dependencies.subscriptionService.syncFromAccess()
                }
            }
        }
    }

    private var authForm: some View {
        WCSCard {
            VStack(spacing: 14) {
                Picker("Mode", selection: $isRegistering) {
                    Text("Sign in").tag(false)
                    Text("Register").tag(true)
                }
                .pickerStyle(.segmented)

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)

                if isRegistering {
                    TextField("Display name", text: $displayName)
                }

                if let error = dependencies.authSession.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                WCSPrimaryButton(isRegistering ? "Create account" : "Sign in", systemImage: "key.fill") {
                    Task {
                        if isRegistering {
                            _ = await dependencies.authSession.signUp(
                                email: email,
                                password: password,
                                displayName: displayName
                            )
                        } else {
                            _ = await dependencies.authSession.signIn(email: email, password: password)
                        }
                        dependencies.subscriptionService.syncFromAccess()
                    }
                }
            }
        }
    }

    private var entitlementsPanel: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your feature access")
                    .font(.headline)
                ForEach(AppFeature.allCases.filter { $0 != .adminPanel }) { feature in
                    let decision = dependencies.accessControl.canAccess(feature)
                    HStack {
                        Image(systemName: feature.systemImage)
                            .foregroundStyle(decision.allowed ? WCSTheme.goldMid : .gray)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.displayName)
                                .font(.subheadline.weight(.medium))
                            Text(decision.reason)
                                .font(.caption2)
                                .foregroundStyle(WCSTheme.secondaryText)
                        }
                        Spacer()
                        Image(systemName: decision.allowed ? "checkmark.circle.fill" : "lock.fill")
                            .foregroundStyle(decision.allowed ? .green : .orange)
                    }
                }
            }
        }
    }

    private var testFlightPanel: some View {
        WCSCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("TestFlight access")
                    .font(.headline)
                Text(
                    "Install via TestFlight (build from ASC \(AppStoreConnect.appID)). " +
                    "An administrator must approve your account for beta entitlements."
                )
                .font(.caption)
                .foregroundStyle(WCSTheme.secondaryText)
                if let user = dependencies.authSession.currentUser, !user.testFlightApproved {
                    Text("Status: awaiting admin approval")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}
