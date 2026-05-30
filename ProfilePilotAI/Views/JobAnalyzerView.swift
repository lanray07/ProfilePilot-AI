import SwiftUI

struct JobAnalyzerView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let profile: UserProfile
    @State private var jobAdvert = """
    Senior Policy Officer - Public Service Delivery

    We are looking for a confident policy professional to lead a workstream improving service outcomes for citizens. You will analyse complex evidence, brief senior stakeholders, coordinate delivery partners, and turn policy intent into practical recommendations.

    Essential criteria:
    - Experience using evidence to make sound recommendations.
    - Strong written and verbal communication for senior audiences.
    - Ability to work collaboratively across teams and manage competing deadlines.
    - Track record of delivering improvements in a public service or regulated environment.

    Behaviours assessed:
    Communicating & Influencing, Making Effective Decisions, Delivering at Pace, Seeing the Big Picture.

    Interview will include behaviour and strengths questions.
    """

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Job Description Analyzer")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "StarWorkspace", title: "Extract the scoring story", subtitle: "Turn advert language into behaviours, risks, and interview strategy.")
                TextEditor(text: $jobAdvert)
                    .frame(minHeight: 180)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(PremiumTheme.ink)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                HStack {
                    PlaceholderUploadButton(title: "PDF", icon: "doc.richtext")
                    PlaceholderUploadButton(title: "Screenshot", icon: "photo")
                }
                PremiumButton(title: viewModel.isLoading ? "Analyzing..." : "Generate Strategy", icon: "sparkles") {
                    Task { await viewModel.analyzeJob(jobAdvert, role: profile.targetRole) }
                }
                if let analysis = viewModel.latestAnalysis {
                    AnalysisResultView(analysis: analysis)
                } else {
                    PremiumEmptyState(title: "No analysis yet", message: "Paste an advert to extract behaviours, strengths, criteria, risks, and scoring opportunities.", icon: "doc.text.magnifyingglass")
                }
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Analyzer")
    }
}

private struct PlaceholderUploadButton: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(PremiumTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct AnalysisResultView: View {
    let analysis: JobAnalysis

    var body: some View {
        VStack(spacing: 12) {
            ResultListCard(title: "Behaviours", icon: "checklist", items: analysis.behaviours)
            ResultListCard(title: "Strengths", icon: "bolt", items: analysis.strengths)
            ResultListCard(title: "Essential Criteria", icon: "seal", items: analysis.essentialCriteria)
            ResultListCard(title: "Interview Risks", icon: "exclamationmark.triangle", items: analysis.interviewRisks)
            ResultListCard(title: "Scoring Opportunities", icon: "target", items: analysis.scoringOpportunities)
            PremiumDashboardCard(title: "Application Strategy", subtitle: "Interview roadmap included", icon: "map") {
                Text(analysis.strategy)
                    .foregroundStyle(PremiumTheme.ink)
                ForEach(analysis.roadmap, id: \.self) { step in
                    Label(step, systemImage: "arrow.right.circle")
                        .foregroundStyle(PremiumTheme.muted)
                        .font(.callout)
                }
            }
        }
    }
}

struct ResultListCard: View {
    let title: String
    let icon: String
    let items: [String]

    var body: some View {
        PremiumDashboardCard(title: title, icon: icon) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                        .font(.callout)
                        .foregroundStyle(PremiumTheme.ink.opacity(0.9))
                }
            }
        }
    }
}
