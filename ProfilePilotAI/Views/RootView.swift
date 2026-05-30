import SwiftData
import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = AppViewModel()
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]

    var body: some View {
        Group {
            if let profile = profiles.first {
                AppShellView(profile: profile)
                    .environmentObject(viewModel)
            } else {
                OnboardingView()
            }
        }
        .tint(PremiumTheme.gold)
    }
}

struct AppShellView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let profile: UserProfile

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            TabView(selection: $viewModel.selectedTab) {
                DashboardView(profile: profile)
                    .tag(AppTab.dashboard)
                    .tabItem { Label(AppTab.dashboard.rawValue, systemImage: AppTab.dashboard.icon) }
                CoachingHomeView()
                    .tag(AppTab.coaching)
                    .tabItem { Label(AppTab.coaching.rawValue, systemImage: AppTab.coaching.icon) }
                LibraryHomeView()
                    .tag(AppTab.library)
                    .tabItem { Label(AppTab.library.rawValue, systemImage: AppTab.library.icon) }
                ProgressHomeView(profile: profile)
                    .tag(AppTab.progress)
                    .tabItem { Label(AppTab.progress.rawValue, systemImage: AppTab.progress.icon) }
            }
            .background(PremiumBackground())
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .jobAnalyzer: JobAnalyzerView(profile: profile)
                case .starBuilder: STARBuilderView()
                case .voiceCoaching: VoiceCoachingView()
                case .mockInterview: MockInterviewView()
                case .successProfiles: SuccessProfilesCoachView()
                case .behaviourLibrary: BehaviourLibraryView()
                case .applicationBuilder: ApplicationBuilderView()
                case .applicationTracker: ApplicationTrackerView()
                case .confidenceDashboard: ConfidenceDashboardView()
                case .careerRoadmap: CareerRoadmapView(profile: profile)
                case .shareCards: PremiumShareCardsView()
                case .paywall: PaywallView()
                }
            }
        }
    }
}
