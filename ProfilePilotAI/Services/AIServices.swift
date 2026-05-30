import Foundation

protocol AIService {
    func analyzeJobDescription(_ text: String, targetRole: String) async throws -> JobAnalysis
    func generateSTAR(situation: String, task: String, action: String, result: String, competency: String) async throws -> STARGenerationResult
    func coachInterview(answer: String, interviewType: String) async throws -> InterviewFeedback
    func buildRoadmap(profile: UserProfile?) async throws -> CareerRoadmap
    func generateFromVoice(transcript: String, module: String) async throws -> String
}

struct JobAnalysisService {
    let ai: AIService

    func analyze(_ text: String, targetRole: String) async throws -> JobAnalysis {
        try await ai.analyzeJobDescription(text, targetRole: targetRole)
    }
}

struct STARGenerationService {
    let ai: AIService

    func generate(situation: String, task: String, action: String, result: String, competency: String) async throws -> STARGenerationResult {
        try await ai.generateSTAR(situation: situation, task: task, action: action, result: result, competency: competency)
    }
}

struct InterviewCoachingService {
    let ai: AIService

    func score(answer: String, interviewType: String) async throws -> InterviewFeedback {
        try await ai.coachInterview(answer: answer, interviewType: interviewType)
    }
}

struct CareerRoadmapService {
    let ai: AIService

    func roadmap(for profile: UserProfile?) async throws -> CareerRoadmap {
        try await ai.buildRoadmap(profile: profile)
    }
}

struct VoiceCoachingService {
    let ai: AIService

    func generate(transcript: String, module: String) async throws -> String {
        try await ai.generateFromVoice(transcript: transcript, module: module)
    }
}

struct MockAIService: AIService {
    private let notice = "\n\n\(ComplianceNotice.text)"

    func analyzeJobDescription(_ text: String, targetRole: String) async throws -> JobAnalysis {
        let role = targetRole.isEmpty ? "target role" : targetRole
        return JobAnalysis(
            behaviours: ["Communicating & Influencing", "Making Effective Decisions", "Delivering at Pace"],
            strengths: ["Adaptable", "Relationship builder", "Analytical thinker"],
            essentialCriteria: ["Evidence of stakeholder management", "Clear written judgement", "Ability to deliver under pressure"],
            desirableCriteria: ["Public sector policy exposure", "Experience improving services"],
            competencies: ["Leadership", "Managing a Quality Service"],
            interviewRisks: ["Answer may drift into duties rather than impact", "Quantified results need strengthening"],
            scoringOpportunities: ["Lead with scale, complexity, and public value", "Name obstacles and decisions", "Finish with measurable outcomes"],
            strategy: "Position your experience as evidence for \(role): open each response with context, show judgement, and connect the result to service outcomes.\(notice)",
            roadmap: ["Extract criteria", "Map two STAR examples per behaviour", "Prepare strengths answers", "Run a panel simulation"]
        )
    }

    func generateSTAR(situation: String, task: String, action: String, result: String, competency: String) async throws -> STARGenerationResult {
        let polished = """
        Situation: \(situation.isEmpty ? "I was working in a high-pressure public service environment with competing priorities." : situation)
        Task: \(task.isEmpty ? "I needed to restore clarity, keep stakeholders aligned, and protect delivery quality." : task)
        Action: \(action.isEmpty ? "I clarified the objective, prioritised evidence, briefed stakeholders, and created a focused delivery plan." : action)
        Result: \(result.isEmpty ? "The work landed on time, confidence improved, and the team adopted the approach for future cases." : result)
        \(notice)
        """
        return STARGenerationResult(
            polishedAnswer: polished,
            successProfileAlignment: "Aligned to \(competency) through clear ownership, judgement, stakeholder communication, and measurable public value.",
            interviewVersion: "In interview, deliver this as a confident two-minute answer with a crisp result and one reflective learning point.",
            applicationVersion: "For an application, compress the context, expand the action, and quantify the result where possible.",
            strongerExamples: ["Add a metric or scale indicator.", "Mention a difficult trade-off.", "Close with what changed because of your action."]
        )
    }

    func coachInterview(answer: String, interviewType: String) async throws -> InterviewFeedback {
        InterviewFeedback(
            score: answer.count > 180 ? 82 : 68,
            starScore: answer.localizedCaseInsensitiveContains("result") ? 84 : 64,
            clarity: "Strong central idea. Tighten the opening sentence and remove background that does not affect the panel score.",
            structure: "STAR structure is visible; make the Action section the longest part of the answer.",
            recommendations: ["Quantify the result", "Name the behaviour explicitly", "End with a concise reflection"]
        )
    }

    func buildRoadmap(profile: UserProfile?) async throws -> CareerRoadmap {
        let role = profile?.targetRole.isEmpty == false ? profile?.targetRole ?? "next role" : "next public sector role"
        return CareerRoadmap(
            promotionPathway: "Build a six-week readiness sprint for \(role), moving from evidence capture to mock panel performance.",
            skillGaps: ["Policy judgement", "Quantified impact storytelling", "Executive stakeholder confidence"],
            competencyGaps: ["Seeing the Big Picture", "Making Effective Decisions"],
            nextRoles: ["Senior Officer", "Policy Advisor", "Service Improvement Lead"],
            developmentPlan: ["Audit evidence bank", "Create two senior-level STAR examples", "Practise strengths questions twice weekly", "Export an interview pack before shortlisting"]
        )
    }

    func generateFromVoice(transcript: String, module: String) async throws -> String {
        """
        \(module) draft:
        \(transcript.isEmpty ? "Speak or paste a real achievement to generate tailored coaching." : transcript)

        Coaching note: shape this into a concise evidence story with context, action, measurable result, and reflection.
        \(ComplianceNotice.text)
        """
    }
}

struct RemoteAIService: AIService {
    var endpoint = URL(string: "https://YOUR_BACKEND_URL.com/profilepilot-ai")!
    var fallback = MockAIService()

    func analyzeJobDescription(_ text: String, targetRole: String) async throws -> JobAnalysis {
        try await fallback.analyzeJobDescription(text, targetRole: targetRole)
    }

    func generateSTAR(situation: String, task: String, action: String, result: String, competency: String) async throws -> STARGenerationResult {
        try await fallback.generateSTAR(situation: situation, task: task, action: action, result: result, competency: competency)
    }

    func coachInterview(answer: String, interviewType: String) async throws -> InterviewFeedback {
        try await fallback.coachInterview(answer: answer, interviewType: interviewType)
    }

    func buildRoadmap(profile: UserProfile?) async throws -> CareerRoadmap {
        try await fallback.buildRoadmap(profile: profile)
    }

    func generateFromVoice(transcript: String, module: String) async throws -> String {
        try await fallback.generateFromVoice(transcript: transcript, module: module)
    }
}
