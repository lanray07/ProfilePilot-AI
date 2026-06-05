import Charts
import StoreKit
import SwiftUI

enum PremiumTheme {
    static let navy = Color(red: 0.025, green: 0.055, blue: 0.12)
    static let navy2 = Color(red: 0.055, green: 0.095, blue: 0.18)
    static let ink = Color(red: 0.88, green: 0.92, blue: 0.98)
    static let muted = Color(red: 0.62, green: 0.68, blue: 0.76)
    static let gold = Color(red: 0.88, green: 0.68, blue: 0.28)
    static let green = Color(red: 0.36, green: 0.78, blue: 0.58)
    static let coral = Color(red: 0.93, green: 0.44, blue: 0.38)

    static var background: LinearGradient {
        LinearGradient(colors: [navy, Color(red: 0.02, green: 0.025, blue: 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct PremiumBackground: View {
    var body: some View {
        PremiumTheme.background.ignoresSafeArea()
    }
}

struct PremiumDashboardCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let icon: String
    @ViewBuilder var content: Content

    init(title: String, subtitle: String? = nil, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(PremiumTheme.gold)
                    .frame(width: 34, height: 34)
                    .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(PremiumTheme.ink)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(PremiumTheme.muted)
                    }
                }
                Spacer()
            }
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.055))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.11)))
        )
    }
}

struct PremiumButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .foregroundStyle(.black)
                .background(PremiumTheme.gold, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct PremiumHeroImage: View {
    let name: String
    let height: CGFloat

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.58), .clear, .black.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.12)))
    }
}

struct BrandedHeroPanel<Content: View>: View {
    let imageName: String
    let height: CGFloat
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            PremiumHeroImage(name: imageName, height: height)
            VStack(alignment: .leading, spacing: 8) {
                Image("LogoMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                content
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct FeatureImageCard: View {
    let imageName: String
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.82))
            }
            .padding(14)
        }
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.12)))
    }
}

struct UpgradeBanner: View {
    let action: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "crown")
                .foregroundStyle(PremiumTheme.gold)
                .font(.title3)
            VStack(alignment: .leading, spacing: 3) {
                Text("Career Accelerator")
                    .foregroundStyle(PremiumTheme.ink)
                    .font(.subheadline.weight(.bold))
                Text("Unlock executive simulations, advanced analytics, and premium templates.")
                    .foregroundStyle(PremiumTheme.muted)
                    .font(.caption)
            }
            Spacer()
            Button(action: action) {
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.black)
                    .frame(width: 34, height: 34)
                    .background(PremiumTheme.gold, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.08)))
    }
}

struct ConfidenceScoreRing: View {
    let score: Double
    let label: String

    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.12), lineWidth: 12)
            Circle()
                .trim(from: 0, to: max(0.02, min(score, 1)))
                .stroke(PremiumTheme.gold, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(Int(score * 100))")
                    .font(.title.bold())
                    .foregroundStyle(PremiumTheme.ink)
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(PremiumTheme.muted)
            }
        }
        .frame(width: 116, height: 116)
    }
}

struct STARCard: View {
    let competency: String
    let content: String
    let score: Int

    var body: some View {
        PremiumDashboardCard(title: competency, subtitle: "STAR evidence score \(score)", icon: "checkmark.seal") {
            Text(content)
                .font(.callout)
                .foregroundStyle(PremiumTheme.ink.opacity(0.92))
                .lineLimit(6)
        }
    }
}

struct InterviewCard: View {
    let mode: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "person.2.wave.2")
                    .foregroundStyle(PremiumTheme.gold)
                    .font(.title3)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode)
                        .foregroundStyle(PremiumTheme.ink)
                        .font(.headline)
                    Text(description)
                        .foregroundStyle(PremiumTheme.muted)
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(PremiumTheme.muted)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.055)))
        }
        .buttonStyle(.plain)
    }
}

struct VoiceWaveformView: View {
    let levels: [CGFloat]
    let isActive: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            ForEach(levels.indices, id: \.self) { index in
                Capsule()
                    .fill(isActive ? PremiumTheme.gold : PremiumTheme.muted.opacity(0.45))
                    .frame(width: 5, height: max(10, levels[index] * 76))
                    .animation(.smooth(duration: 0.28), value: levels[index])
            }
        }
        .frame(height: 86)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct AnalyticsChartCard: View {
    struct Point: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
    }

    let title: String
    let points: [Point]

    var body: some View {
        PremiumDashboardCard(title: title, subtitle: "Readiness trend", icon: "chart.xyaxis.line") {
            Chart(points) { point in
                LineMark(x: .value("Stage", point.label), y: .value("Score", point.value))
                    .foregroundStyle(PremiumTheme.gold)
                    .interpolationMethod(.catmullRom)
                AreaMark(x: .value("Stage", point.label), y: .value("Score", point.value))
                    .foregroundStyle(PremiumTheme.gold.opacity(0.22))
                    .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 0...100)
            .frame(height: 170)
        }
    }
}

struct ShareCardPreview: View {
    let title: String
    let metric: String

    var body: some View {
        ZStack {
            Image("ShareCardBackground")
                .resizable()
                .scaledToFill()
            LinearGradient(colors: [.black.opacity(0.14), .black.opacity(0.68)], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Text("ProfilePilot AI")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(PremiumTheme.gold)
                    Spacer()
                    Image(systemName: "sparkles")
                        .foregroundStyle(PremiumTheme.gold)
                }
                Spacer()
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(PremiumTheme.ink)
                Text(metric)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text(ComplianceNotice.text)
                    .font(.caption2)
                    .foregroundStyle(PremiumTheme.muted)
            }
            .padding(22)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(PremiumTheme.gold.opacity(0.35)))
    }
}

struct PaywallView: View {
    @StateObject private var subscription = SubscriptionService()
    private let privacyURL = URL(string: "https://github.com/lanray07/ProfilePilot-AI/blob/main/PRIVACY_POLICY.md")!
    private let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    var body: some View {
        SubscriptionStoreView(productIDs: SubscriptionPlan.storeProductIDs) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Upgrade Your Public Sector Campaign")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                Text("Unlimited coaching, voice interviews, advanced analytics, executive modes, and premium templates.")
                    .foregroundStyle(PremiumTheme.muted)
                Image("SubscriptionProfessional")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.12)))
                Text("Professional Monthly and Professional Yearly include AI coaching, STAR examples, interview practice, and progress planning.")
                    .font(.callout)
                    .foregroundStyle(PremiumTheme.ink.opacity(0.9))
                Text(ComplianceNotice.text)
                    .font(.footnote)
                    .foregroundStyle(PremiumTheme.muted)
                HStack(spacing: 14) {
                    Link("Privacy Policy", destination: privacyURL)
                    Link("Terms of Use", destination: termsURL)
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(PremiumTheme.gold)
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Plans")
        .subscriptionStoreControlStyle(.buttons)
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStorePolicyDestination(url: privacyURL, for: .privacyPolicy)
        .subscriptionStorePolicyDestination(url: termsURL, for: .termsOfService)
        .storeButton(.visible, for: .restorePurchases)
        .task {
            await subscription.loadProducts()
            await subscription.updateEntitlements()
        }
    }
}

struct PremiumEmptyState: View {
    let title: String
    let message: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image("EmptyState")
                .resizable()
                .scaledToFit()
                .frame(height: 92)
                .accessibilityHidden(true)
            Text(title)
                .font(.headline)
                .foregroundStyle(PremiumTheme.ink)
            Text(message)
                .font(.callout)
                .foregroundStyle(PremiumTheme.muted)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
    }
}
