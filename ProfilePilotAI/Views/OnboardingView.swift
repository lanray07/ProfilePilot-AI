import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var organization = TargetOrganization.civilService
    @State private var targetRole = "Policy Officer"
    @State private var grade = "HEO"
    @State private var confidence = 0.55
    @State private var style = CoachingStyle.executive

    private let grades = ["EO", "HEO", "SEO", "Grade 7", "Grade 6", "NHS Band 2-8"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                BrandedHeroPanel(imageName: "CoachHero", height: 310) {
                    Text("ProfilePilot AI")
                        .font(.largeTitle.bold())
                        .foregroundStyle(PremiumTheme.ink)
                    Text("The AI career coach for public sector success.")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(PremiumTheme.gold)
                    Text("Turn your experience into winning applications.")
                        .foregroundStyle(PremiumTheme.muted)
                }
                .padding(.top, 28)

                PremiumDashboardCard(title: "Your Target", subtitle: "Personalise the coaching roadmap", icon: "building.columns") {
                    VStack(spacing: 14) {
                        Picker("Organisation", selection: $organization) {
                            ForEach(TargetOrganization.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        PremiumTextField(title: "Target role", text: $targetRole)
                        Picker("Target grade", selection: $grade) {
                            ForEach(grades, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                PremiumDashboardCard(title: "Coaching Profile", subtitle: "Shape the tone and intensity", icon: "person.crop.circle.badge.checkmark") {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Confidence level: \(Int(confidence * 100))")
                            .foregroundStyle(PremiumTheme.ink)
                        Slider(value: $confidence, in: 0.1...1)
                        Picker("Coaching style", selection: $style) {
                            ForEach(CoachingStyle.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                PremiumDashboardCard(title: "Readiness Preview", subtitle: "Generated from your profile", icon: "map") {
                    HStack(spacing: 20) {
                        ConfidenceScoreRing(score: confidence, label: "Ready")
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Career profile", systemImage: "checkmark.circle")
                            Label("Readiness dashboard", systemImage: "checkmark.circle")
                            Label("Personalised roadmap", systemImage: "checkmark.circle")
                        }
                        .foregroundStyle(PremiumTheme.ink)
                        .font(.callout.weight(.medium))
                    }
                }

                PremiumButton(title: "Build My Roadmap", icon: "sparkles") {
                    let profile = UserProfile(
                        targetOrganization: organization.rawValue,
                        targetRole: targetRole,
                        targetGrade: grade,
                        confidenceLevel: confidence,
                        coachingStyle: style.rawValue
                    )
                    modelContext.insert(profile)
                    modelContext.insert(SubscriptionState())
                    seedAchievements()
                }

                Text(ComplianceNotice.text)
                    .font(.footnote)
                    .foregroundStyle(PremiumTheme.muted)
            }
            .padding()
        }
        .background(PremiumBackground())
    }

    private func seedAchievements() {
        ["Interview Ready", "Application Submitted", "STAR Mastery", "Success Profile Progress"].forEach {
            modelContext.insert(Achievement(title: $0, detail: "Premium share card placeholder", unlocked: false))
        }
    }
}

private struct PremiumTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textInputAutocapitalization(.words)
            .padding(12)
            .foregroundStyle(PremiumTheme.ink)
            .background(.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.12)))
    }
}
