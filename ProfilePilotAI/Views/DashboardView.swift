import SwiftData
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Query private var applications: [JobApplication]
    @Query private var starExamples: [STARExample]
    @Query private var sessions: [InterviewSession]
    @Query private var subscriptions: [SubscriptionState]
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                UpgradeBanner { viewModel.path.append(.paywall) }
                metricsGrid
                quickActions
                AnalyticsChartCard(
                    title: "Confidence Trend",
                    points: [
                        .init(label: "Start", value: profile.confidenceLevel * 100),
                        .init(label: "STAR", value: 68),
                        .init(label: "Mock", value: 74),
                        .init(label: "Panel", value: 82)
                    ]
                )
                PremiumDashboardCard(title: "AI Coaching Insights", subtitle: "Mock AI enabled", icon: "sparkles") {
                    Text("Your next best move is to strengthen two quantified STAR examples and run one executive panel simulation before submission.")
                        .foregroundStyle(PremiumTheme.ink.opacity(0.92))
                    Text(ComplianceNotice.text)
                        .font(.caption)
                        .foregroundStyle(PremiumTheme.muted)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Dashboard")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Good evening")
                .font(.caption.weight(.semibold))
                .foregroundStyle(PremiumTheme.gold)
            Text(profile.targetRole.isEmpty ? "Your Public Sector Campaign" : profile.targetRole)
                .font(.largeTitle.bold())
                .foregroundStyle(PremiumTheme.ink)
            Text("\(profile.targetOrganization) • \(profile.targetGrade) • \(profile.coachingStyle) coaching")
                .foregroundStyle(PremiumTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "Active Applications", value: "\(applications.count)", icon: "folder")
            MetricCard(title: "Interview Readiness", value: "\(Int(profile.confidenceLevel * 100))%", icon: "person.2")
            MetricCard(title: "Strengths Score", value: "78", icon: "bolt")
            MetricCard(title: "Behaviour Score", value: "\(starExamples.map(\.score).max() ?? 64)", icon: "checkmark.seal")
            MetricCard(title: "STAR Library", value: "\(starExamples.count)/16", icon: "books.vertical")
            MetricCard(title: "Plan", value: subscriptions.first?.plan ?? "Free", icon: "crown")
        }
    }

    private var quickActions: some View {
        PremiumDashboardCard(title: "Quick Actions", subtitle: "Build, rehearse, export", icon: "wand.and.stars") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ActionButton("Paste Job Advert", "doc.text.magnifyingglass", .jobAnalyzer)
                ActionButton("Build STAR Example", "square.and.pencil", .starBuilder)
                ActionButton("Voice Coaching", "waveform", .voiceCoaching)
                ActionButton("Mock Interview", "person.2.wave.2", .mockInterview)
                ActionButton("Application Tracker", "tray.full", .applicationTracker)
                ActionButton("Success Profiles", "building.columns", .successProfiles)
            }
        }
    }

    private func ActionButton(_ title: String, _ icon: String, _ route: AppRoute) -> some View {
        Button {
            viewModel.path.append(route)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.title3)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .foregroundStyle(PremiumTheme.ink)
            .frame(maxWidth: .infinity, minHeight: 86)
            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(PremiumTheme.gold)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(PremiumTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(PremiumTheme.muted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 8))
    }
}
