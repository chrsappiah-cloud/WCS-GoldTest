import SwiftUI

enum WCSTheme {
    // MARK: - Gold palette

    static let goldLight = Color(red: 0.96, green: 0.84, blue: 0.45)
    static let goldMid = Color(red: 0.85, green: 0.68, blue: 0.24)
    static let goldDeep = Color(red: 0.72, green: 0.52, blue: 0.12)
    static let goldShimmer = Color(red: 1.0, green: 0.92, blue: 0.55)

    // MARK: - Diamond / jewel tones

    static let diamondIce = Color(red: 0.88, green: 0.94, blue: 1.0)
    static let diamondSpark = Color(red: 0.75, green: 0.88, blue: 0.98)
    static let amethystAccent = Color(red: 0.55, green: 0.42, blue: 0.78)

    // MARK: - Dark luxury base

    static let obsidian = Color(red: 0.06, green: 0.06, blue: 0.09)
    static let charcoal = Color(red: 0.11, green: 0.11, blue: 0.14)
    static let slateCard = Color(red: 0.14, green: 0.14, blue: 0.18)

    // MARK: - Semantic (adaptive)

    static var accent: Color { goldMid }
    static var accentGradient: LinearGradient { goldGradient }
    static var screenBackground: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(WCSTheme.obsidian)
                : UIColor(red: 0.97, green: 0.96, blue: 0.94, alpha: 1)
        })
    }
    static var cardBackground: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(WCSTheme.slateCard)
                : UIColor.white
        })
    }
    static var primaryText: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : UIColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1)
        })
    }
    static var secondaryText: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.72, alpha: 1)
                : UIColor(red: 0.38, green: 0.34, blue: 0.30, alpha: 1)
        })
    }

    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [goldShimmer, goldMid, goldDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var diamondGradient: LinearGradient {
        LinearGradient(
            colors: [diamondIce, diamondSpark, diamondIce.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var luxuryBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                obsidian,
                charcoal,
                Color(red: 0.10, green: 0.09, blue: 0.14),
                obsidian,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let disclaimer = """
    Results are screening estimates, not laboratory certification. \
    Home testing does not replace accredited assay or gemological laboratory analysis.
    """
}

// MARK: - Luxury background with sparkles

struct LuxuryScreenBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                WCSTheme.luxuryBackgroundGradient
                SparkleField(count: 48, opacity: 0.55)
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.97, blue: 0.93),
                        Color(red: 0.95, green: 0.90, blue: 0.82),
                        Color(red: 0.98, green: 0.96, blue: 0.92),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                SparkleField(count: 28, opacity: 0.35)
            }
        }
        .ignoresSafeArea()
    }
}

struct SparkleField: View {
    let count: Int
    let opacity: Double

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geo in
                let t = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    ForEach(0..<count, id: \.self) { i in
                        let seed = Double(i * 7919)
                        let x = (sin(seed * 0.31 + t * 0.4) * 0.5 + 0.5) * geo.size.width
                        let y = (cos(seed * 0.17 + t * 0.3) * 0.5 + 0.5) * geo.size.height
                        let flicker = 0.35 + 0.65 * abs(sin(t * 2.5 + seed))
                        let radius = 1.2 + Double(i % 3)
                        Circle()
                            .fill(
                                (i % 4 == 0 ? WCSTheme.diamondIce : WCSTheme.goldShimmer)
                                    .opacity(opacity * flicker)
                            )
                            .frame(width: radius * 2, height: radius * 2)
                            .position(x: x, y: y)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct DiamondDivider: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(WCSTheme.goldGradient)
                .frame(height: 1)
            Image(systemName: "diamond.fill")
                .font(.caption2)
                .foregroundStyle(WCSTheme.diamondGradient)
            Rectangle()
                .fill(WCSTheme.goldGradient)
                .frame(height: 1)
        }
        .padding(.vertical, 4)
    }
}

struct WCSCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(WCSTheme.primaryText)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(WCSTheme.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: colorScheme == .dark
                                        ? [WCSTheme.goldMid.opacity(0.5), WCSTheme.diamondSpark.opacity(0.25), .clear]
                                        : [WCSTheme.goldShimmer.opacity(0.8), WCSTheme.goldMid.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: colorScheme == .dark
                            ? WCSTheme.goldMid.opacity(0.12)
                            : .black.opacity(0.06),
                        radius: 12,
                        y: 4
                    )
            }
    }
}

struct WCSPrimaryButton: View {
    let title: String
    let systemImage: String?
    let accessibilityIdentifier: String?
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.04))
            .background(WCSTheme.goldGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(WCSTheme.goldShimmer.opacity(0.6), lineWidth: 1)
            }
            .shadow(color: WCSTheme.goldDeep.opacity(0.35), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier ?? title)
    }
}

struct WCSSecondaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage ?? "")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(WCSTheme.goldMid)
    }
}

struct WCSConfidenceBadge: View {
    let confidence: Double

    var body: some View {
        Text("Confidence \(Int(confidence * 100))%")
            .font(.caption.weight(.bold))
            .foregroundStyle(WCSTheme.obsidian)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(WCSTheme.goldGradient, in: Capsule())
            .overlay(Capsule().strokeBorder(WCSTheme.goldShimmer, lineWidth: 0.5))
    }
}

struct WCSNavBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func wcsLuxuryScreen() -> some View {
        ZStack {
            LuxuryScreenBackground()
            self
        }
    }

    func wcsNavigationStyle() -> some View {
        modifier(WCSNavBarStyle())
    }
}
