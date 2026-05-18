import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Screen jewelry at home",
            subtitle: "Estimate likely purity ranges with guided scans.",
            image: "circle.hexagongrid.fill"
        ),
        OnboardingPage(
            title: "Connect your probe",
            subtitle: "Pair WCS hardware for more reliable readings than camera-only apps.",
            image: "antenna.radiowaves.left.and.right"
        ),
        OnboardingPage(
            title: "Track & report",
            subtitle: "Save vault history and export screening reports with clear disclaimers.",
            image: "doc.richtext"
        ),
    ]

    var body: some View {
        VStack(spacing: 32) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 16) {
                        Image(systemName: page.image)
                            .font(.system(size: 56))
                            .foregroundStyle(WCSTheme.goldGradient)
                            .shadow(color: WCSTheme.goldMid.opacity(0.5), radius: 12)
                        Text(page.title)
                            .font(.title2.bold())
                            .foregroundStyle(WCSTheme.primaryText)
                            .multilineTextAlignment(.center)
                        Text(page.subtitle)
                            .font(.body)
                            .foregroundStyle(WCSTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)

            WCSPrimaryButton(page < pages.count - 1 ? "Continue" : "Get started", systemImage: "arrow.right") {
                if page < pages.count - 1 {
                    page += 1
                } else {
                    onComplete()
                }
            }
            .padding(.horizontal)

            Button("Skip") { onComplete() }
                .font(.footnote)
                .foregroundStyle(WCSTheme.secondaryText)
        }
        .padding(.vertical)
        .wcsLuxuryScreen()
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let image: String
}
