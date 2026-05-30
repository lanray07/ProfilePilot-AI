import SwiftData
import SwiftUI

struct MockInterviewView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var type = "Civil Service"
    @State private var mode = "Executive panel simulation"
    @State private var answer = ""

    private let types = ["Civil Service", "NHS", "Strengths", "Behaviour", "Fast Stream", "Blended"]
    private let modes = ["Text", "Voice", "Rapid-fire", "Executive panel simulation"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("AI Mock Interview")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                Picker("Interview type", selection: $type) {
                    ForEach(types, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                Picker("Mode", selection: $mode) {
                    ForEach(modes, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
                PremiumDashboardCard(title: "\(type) Question", subtitle: mode, icon: "person.2.wave.2") {
                    Text("Tell us about a time you used evidence and judgement to influence a difficult decision.")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(PremiumTheme.ink)
                }
                TextEditor(text: $answer)
                    .frame(minHeight: 160)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(PremiumTheme.ink)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                PremiumButton(title: "Score My Answer", icon: "chart.bar") {
                    Task { await viewModel.scoreInterview(answer: answer, type: type) }
                }
                if let feedback = viewModel.latestFeedback {
                    PremiumDashboardCard(title: "Interview Feedback", subtitle: "Score \(feedback.score)", icon: "gauge.with.dots.needle.67percent") {
                        HStack {
                            ConfidenceScoreRing(score: Double(feedback.score) / 100, label: "Overall")
                            ConfidenceScoreRing(score: Double(feedback.starScore) / 100, label: "STAR")
                        }
                        Text(feedback.clarity).foregroundStyle(PremiumTheme.ink)
                        Text(feedback.structure).foregroundStyle(PremiumTheme.muted)
                    }
                    ResultListCard(title: "Recommendations", icon: "arrow.up.forward", items: feedback.recommendations)
                    PremiumButton(title: "Save Session", icon: "tray.and.arrow.down") {
                        modelContext.insert(InterviewSession(type: type, score: feedback.score, transcript: answer, feedback: feedback.recommendations))
                    }
                }
                Text(ComplianceNotice.text)
                    .font(.footnote)
                    .foregroundStyle(PremiumTheme.muted)
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Interview")
    }
}
