import Foundation
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .dashboard
    @Published var path: [AppRoute] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var latestAnalysis: JobAnalysis?
    @Published var latestSTAR: STARGenerationResult?
    @Published var latestFeedback: InterviewFeedback?
    @Published var latestRoadmap: CareerRoadmap?
    @Published var generatedVoiceOutput = ""

    let jobAnalysis: JobAnalysisService
    let starBuilder: STARGenerationService
    let interviewCoach: InterviewCoachingService
    let careerRoadmap: CareerRoadmapService
    let voiceCoach: VoiceCoachingService

    init(ai: AIService = MockAIService()) {
        jobAnalysis = JobAnalysisService(ai: ai)
        starBuilder = STARGenerationService(ai: ai)
        interviewCoach = InterviewCoachingService(ai: ai)
        careerRoadmap = CareerRoadmapService(ai: ai)
        voiceCoach = VoiceCoachingService(ai: ai)
    }

    func analyzeJob(_ text: String, role: String) async {
        await run {
            latestAnalysis = try await jobAnalysis.analyze(text, targetRole: role)
        }
    }

    func generateSTAR(situation: String, task: String, action: String, result: String, competency: String) async {
        await run {
            latestSTAR = try await starBuilder.generate(situation: situation, task: task, action: action, result: result, competency: competency)
        }
    }

    func scoreInterview(answer: String, type: String) async {
        await run {
            latestFeedback = try await interviewCoach.score(answer: answer, interviewType: type)
        }
    }

    func loadRoadmap(profile: UserProfile?) async {
        await run {
            latestRoadmap = try await careerRoadmap.roadmap(for: profile)
        }
    }

    func generateFromVoice(transcript: String, module: String) async {
        await run {
            generatedVoiceOutput = try await voiceCoach.generate(transcript: transcript, module: module)
        }
    }

    private func run(_ operation: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case coaching = "Coaching"
    case library = "Library"
    case progress = "Progress"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard:
            return "gauge.with.dots.needle.50percent"
        case .coaching:
            return "sparkles"
        case .library:
            return "books.vertical"
        case .progress:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

enum AppRoute: Hashable {
    case jobAnalyzer
    case starBuilder
    case voiceCoaching
    case mockInterview
    case successProfiles
    case behaviourLibrary
    case applicationBuilder
    case applicationTracker
    case confidenceDashboard
    case careerRoadmap
    case shareCards
    case paywall
}
