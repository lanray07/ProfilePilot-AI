import SwiftData
import SwiftUI

struct CoachingHomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Coaching Suite")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "InterviewPanel", title: "Human coaching, structured by AI", subtitle: "Prepare with calm, premium, realistic practice modes.")
                InterviewCard(mode: "Success Profiles Coach", description: "Behaviours, strengths, experience, and technical skills.") { viewModel.path.append(.successProfiles) }
                InterviewCard(mode: "AI STAR Builder", description: "Polish evidence into interview and application versions.") { viewModel.path.append(.starBuilder) }
                InterviewCard(mode: "Voice Coaching", description: "Speak achievements and generate structured answers.") { viewModel.path.append(.voiceCoaching) }
                InterviewCard(mode: "Mock Interview", description: "Civil Service, NHS, Fast Stream, and panel simulations.") { viewModel.path.append(.mockInterview) }
            }
            .padding()
        }
        .background(PremiumBackground())
    }
}

struct LibraryHomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Evidence Library")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "StarWorkspace", title: "Your evidence bank", subtitle: "Keep achievements ready for applications, interviews, and promotions.")
                InterviewCard(mode: "Behaviour Library", description: "Search, tag, and filter STAR stories.") { viewModel.path.append(.behaviourLibrary) }
                InterviewCard(mode: "Application Builder", description: "Create supporting statements and evidence drafts.") { viewModel.path.append(.applicationBuilder) }
                InterviewCard(mode: "Premium Share Cards", description: "Generate polished readiness milestones.") { viewModel.path.append(.shareCards) }
            }
            .padding()
        }
        .background(PremiumBackground())
    }
}

struct ProgressHomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Progress")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "RoadmapIllustration", title: "A visible path forward", subtitle: "Track readiness, coverage, and career progression.")
                InterviewCard(mode: "Application Tracker", description: "Deadlines, interviews, offers, and decisions.") { viewModel.path.append(.applicationTracker) }
                InterviewCard(mode: "Confidence Dashboard", description: "Coverage, strengths, weaknesses, and readiness.") { viewModel.path.append(.confidenceDashboard) }
                InterviewCard(mode: "AI Career Roadmap", description: "Promotion pathway, gaps, and next-role options.") { viewModel.path.append(.careerRoadmap) }
            }
            .padding()
        }
        .background(PremiumBackground())
    }
}

struct SuccessProfilesCoachView: View {
    private let sections = [
        ("Behaviours", ["Leadership", "Working Together", "Delivering at Pace", "Communicating & Influencing"]),
        ("Strengths", ["Natural motivation", "Energy", "Consistency", "Authentic examples"]),
        ("Experience", ["Evidence bank", "Context", "Scope", "Impact"]),
        ("Technical Skills", ["Role-specific standards", "Policy or clinical knowledge", "Professional judgement"])
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Success Profiles Coach")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "CoachHero", title: "Coach the whole profile", subtitle: "Behaviours, strengths, experience, and technical evidence in one place.")
                ForEach(sections, id: \.0) { section in
                    ResultListCard(title: section.0, icon: "building.columns", items: section.1)
                }
                PremiumDashboardCard(title: "Readiness Report", subtitle: "Template", icon: "doc.text") {
                    Text("Use two evidence examples per behaviour, one strengths story per theme, and a concise closing reflection.")
                        .foregroundStyle(PremiumTheme.ink)
                }
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Success Profiles")
    }
}

struct BehaviourLibraryView: View {
    @Query(sort: \STARExample.createdAt, order: .reverse) private var examples: [STARExample]
    @State private var search = ""

    var filtered: [STARExample] {
        guard !search.isEmpty else { return examples }
        return examples.filter { $0.competency.localizedCaseInsensitiveContains(search) || $0.content.localizedCaseInsensitiveContains(search) || $0.tags.joined(separator: " ").localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Behaviour Library")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                TextField("Search evidence, tags, role filters", text: $search)
                    .padding(12)
                    .foregroundStyle(PremiumTheme.ink)
                    .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
                if filtered.isEmpty {
                    PremiumEmptyState(title: "No saved STAR examples", message: "Generate a STAR answer, save it, then refine it here.", icon: "books.vertical")
                } else {
                    ForEach(filtered) { example in
                        STARCard(competency: example.competency, content: example.content, score: example.score)
                    }
                }
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Library")
    }
}

struct ApplicationBuilderView: View {
    @State private var prompt = """
    Target role: Senior Policy Officer.
    Key evidence: led cross-team service improvement, improved clearance rates, wrote senior briefings, managed competing deadlines, translated operational risk into clear recommendations.
    Tone: professional, concise, evidence-led, suitable for a UK public sector supporting statement.
    """
    @State private var draft = """
    I am an evidence-led public sector professional with experience turning complex operational challenges into clear recommendations for senior decision-makers. In my recent work, I coordinated policy, operations, and communications colleagues during a time-sensitive service improvement project. I used performance data and stakeholder insight to identify the core delivery risks, then produced a focused options paper that helped leaders make a timely decision.

    My strengths are structured judgement, clear communication, and delivery discipline. I am confident working across teams, managing competing deadlines, and translating technical detail into practical action. I would bring a calm, service-focused approach to this role, with a strong commitment to improving outcomes for citizens.

    \(ComplianceNotice.text)
    """
    private let pdf = PDFExportService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Application Builder")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "StarWorkspace", title: "Draft with judgement", subtitle: "Build statements that stay specific, measured, and reviewable.")
                TextEditor(text: $prompt)
                    .frame(minHeight: 140)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(PremiumTheme.ink)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                PremiumButton(title: "Generate Supporting Statement", icon: "doc.text.fill") {
                    draft = "Supporting statement draft\n\nI bring evidence-led judgement, stakeholder confidence, and a delivery mindset. \(prompt)\n\n\(ComplianceNotice.text)"
                }
                if !draft.isEmpty {
                    PremiumDashboardCard(title: "Editable Draft", subtitle: "Supporting statement", icon: "square.and.pencil") {
                        TextEditor(text: $draft)
                            .frame(minHeight: 220)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(PremiumTheme.ink)
                        ShareLink(item: pdf.render(title: "Application Package", sections: [("Draft", draft)]) ?? URL(filePath: NSTemporaryDirectory())) {
                            Label("Export PDF", systemImage: "square.and.arrow.up")
                                .foregroundStyle(PremiumTheme.gold)
                        }
                    }
                }
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Builder")
    }
}

struct ApplicationTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JobApplication.createdAt, order: .reverse) private var applications: [JobApplication]
    @State private var title = "Senior Policy Officer"
    @State private var organization = "Civil Service"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Application Tracker")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                PremiumDashboardCard(title: "Add Application", icon: "plus.circle") {
                    TextField("Role title", text: $title)
                        .padding(10)
                        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
                    TextField("Organisation", text: $organization)
                        .padding(10)
                        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
                    PremiumButton(title: "Track Application", icon: "tray.full") {
                        modelContext.insert(JobApplication(title: title, organization: organization))
                    }
                }
                if applications.isEmpty {
                    PremiumEmptyState(title: "No applications tracked", message: "Add roles to monitor drafting, submissions, interviews, offers, and outcomes.", icon: "tray")
                } else {
                    ForEach(applications) { app in
                        PremiumDashboardCard(title: app.title, subtitle: app.organization, icon: "briefcase") {
                            HStack {
                                Text(app.status)
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(PremiumTheme.gold.opacity(0.18), in: Capsule())
                                Spacer()
                                Text(app.createdAt, style: .date)
                                    .foregroundStyle(PremiumTheme.muted)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Tracker")
    }
}

struct ConfidenceDashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Confidence Dashboard")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "ShareCardBackground", title: "Readiness you can see", subtitle: "Elegant analytics for confidence, coverage, and progress.")
                HStack {
                    ConfidenceScoreRing(score: 0.82, label: "Ready")
                    ConfidenceScoreRing(score: 0.74, label: "Coverage")
                }
                AnalyticsChartCard(title: "Readiness Analytics", points: [
                    .init(label: "Behaviours", value: 76),
                    .init(label: "Strengths", value: 70),
                    .init(label: "STAR", value: 84),
                    .init(label: "Interview", value: 78)
                ])
                ResultListCard(title: "Strongest Competencies", icon: "star", items: ["Communicating & Influencing", "Delivering at Pace"])
                ResultListCard(title: "Weakest Competencies", icon: "arrow.down.circle", items: ["Seeing the Big Picture", "Making Effective Decisions"])
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Confidence")
    }
}

struct CareerRoadmapView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("AI Career Roadmap")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "RoadmapIllustration", title: "Promotion pathway", subtitle: "Map skill gaps, next roles, and development actions.")
                PremiumButton(title: "Generate Roadmap", icon: "map") {
                    Task { await viewModel.loadRoadmap(profile: profile) }
                }
                if let roadmap = viewModel.latestRoadmap {
                    PremiumDashboardCard(title: "Promotion Pathway", icon: "arrow.up.forward") {
                        Text(roadmap.promotionPathway).foregroundStyle(PremiumTheme.ink)
                    }
                    ResultListCard(title: "Skill Gaps", icon: "wrench.adjustable", items: roadmap.skillGaps)
                    ResultListCard(title: "Competency Gaps", icon: "target", items: roadmap.competencyGaps)
                    ResultListCard(title: "Next Role Suggestions", icon: "briefcase", items: roadmap.nextRoles)
                    ResultListCard(title: "Development Plan", icon: "calendar.badge.clock", items: roadmap.developmentPlan)
                }
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Roadmap")
    }
}

struct PremiumShareCardsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Premium Share Cards")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                ShareCardPreview(title: "Interview Ready", metric: "82% readiness")
                ShareCardPreview(title: "Application Submitted", metric: "Draft polished")
                ShareCardPreview(title: "STAR Mastery", metric: "12 examples")
                ShareCardPreview(title: "Success Profile Progress", metric: "6 behaviours")
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Share Cards")
    }
}
