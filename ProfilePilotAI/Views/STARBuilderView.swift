import SwiftData
import SwiftUI

struct STARBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var competency = Competency.communicatingInfluencing
    @State private var situation = "A high-profile service update was at risk because policy, operations, and communications teams were working from different assumptions."
    @State private var task = "I needed to create a shared position within two days, protect delivery confidence, and prepare a clear recommendation for senior leaders."
    @State private var action = "I mapped the decision points, gathered the strongest evidence, chaired a focused stakeholder session, and converted technical risks into plain-language options with clear trade-offs."
    @State private var result = "Senior leaders approved the recommendation, the update launched on schedule, and the briefing format was adopted for future urgent cross-team decisions."

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("AI STAR Builder")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                FeatureImageCard(imageName: "StarWorkspace", title: "Evidence that feels senior", subtitle: "Shape achievements into polished public-sector examples.")
                Picker("Competency", selection: $competency) {
                    ForEach(Competency.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                STARInput(title: "Situation", text: $situation)
                STARInput(title: "Task", text: $task)
                STARInput(title: "Action", text: $action)
                STARInput(title: "Result", text: $result)
                PremiumButton(title: "Polish STAR Answer", icon: "wand.and.stars") {
                    Task {
                        await viewModel.generateSTAR(situation: situation, task: task, action: action, result: result, competency: competency.rawValue)
                    }
                }
                if let star = viewModel.latestSTAR {
                    PremiumDashboardCard(title: "Polished Answer", subtitle: star.successProfileAlignment, icon: "checkmark.seal") {
                        Text(star.polishedAnswer).foregroundStyle(PremiumTheme.ink)
                    }
                    ResultListCard(title: "Stronger Examples", icon: "arrow.up.circle", items: star.strongerExamples)
                    HStack {
                        PremiumButton(title: "Save to Library", icon: "tray.and.arrow.down") {
                            modelContext.insert(STARExample(competency: competency.rawValue, title: competency.rawValue, content: star.polishedAnswer, score: 82, tags: ["AI generated", "Review"]))
                        }
                    }
                }
                Text(ComplianceNotice.text)
                    .font(.footnote)
                    .foregroundStyle(PremiumTheme.muted)
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("STAR Builder")
    }
}

private struct STARInput: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(PremiumTheme.gold)
                .font(.caption.weight(.bold))
            TextEditor(text: $text)
                .frame(minHeight: 86)
                .padding(8)
                .scrollContentBackground(.hidden)
                .foregroundStyle(PremiumTheme.ink)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}
