import Foundation
import SwiftData

enum TargetOrganization: String, CaseIterable, Identifiable {
    case civilService = "Civil Service"
    case nhs = "NHS"
    case localGovernment = "Local Government"
    case police = "Police"
    case education = "Education"
    case other = "Other Public Sector"

    var id: String { rawValue }
}

enum CoachingStyle: String, CaseIterable, Identifiable {
    case supportive = "Supportive"
    case direct = "Direct"
    case executive = "Executive"
    case strict = "Strict"
    case confidenceBuilding = "Confidence-building"

    var id: String { rawValue }
}

enum ApplicationStatus: String, CaseIterable, Identifiable {
    case researching = "Researching"
    case drafting = "Drafting"
    case submitted = "Submitted"
    case interview = "Interview"
    case offer = "Offer"
    case rejected = "Rejected"

    var id: String { rawValue }
}

enum Competency: String, CaseIterable, Identifiable {
    case leadership = "Leadership"
    case workingTogether = "Working Together"
    case deliveringAtPace = "Delivering at Pace"
    case communicatingInfluencing = "Communicating & Influencing"
    case seeingBigPicture = "Seeing the Big Picture"
    case managingQualityService = "Managing a Quality Service"
    case makingEffectiveDecisions = "Making Effective Decisions"
    case developingSelfOthers = "Developing Self and Others"

    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case free = "Free"
    case professionalMonthly = "Professional Monthly"
    case professionalYearly = "Professional Yearly"
    case acceleratorMonthly = "Career Accelerator Monthly"

    var id: String { rawValue }

    var productID: String? {
        switch self {
        case .free:
            return nil
        case .professionalMonthly:
            return "profilepilot.professional.monthly"
        case .professionalYearly:
            return "profilepilot.professional.yearly"
        case .acceleratorMonthly:
            return "profilepilot.accelerator.monthly"
        }
    }

    var price: String {
        switch self {
        case .free:
            return "Limited"
        case .professionalMonthly:
            return "GBP 12.99"
        case .professionalYearly:
            return "GBP 99.99"
        case .acceleratorMonthly:
            return "GBP 24.99"
        }
    }
}

@Model
final class UserProfile {
    var id: UUID
    var targetOrganization: String
    var targetRole: String
    var targetGrade: String
    var confidenceLevel: Double
    var coachingStyle: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        targetOrganization: String = TargetOrganization.civilService.rawValue,
        targetRole: String = "",
        targetGrade: String = "HEO",
        confidenceLevel: Double = 0.55,
        coachingStyle: String = CoachingStyle.executive.rawValue,
        createdAt: Date = .now
    ) {
        self.id = id
        self.targetOrganization = targetOrganization
        self.targetRole = targetRole
        self.targetGrade = targetGrade
        self.confidenceLevel = confidenceLevel
        self.coachingStyle = coachingStyle
        self.createdAt = createdAt
    }
}

@Model
final class JobApplication {
    var id: UUID
    var title: String
    var organization: String
    var status: String
    var deadline: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        organization: String,
        status: String = ApplicationStatus.drafting.rawValue,
        deadline: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.organization = organization
        self.status = status
        self.deadline = deadline
        self.createdAt = createdAt
    }
}

@Model
final class STARExample {
    var id: UUID
    var competency: String
    var title: String
    var content: String
    var score: Int
    var tags: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        competency: String,
        title: String,
        content: String,
        score: Int = 74,
        tags: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.competency = competency
        self.title = title
        self.content = content
        self.score = score
        self.tags = tags
        self.createdAt = createdAt
    }
}

@Model
final class VoiceTranscript {
    var id: UUID
    var transcript: String
    var generatedOutput: String
    var createdAt: Date

    init(id: UUID = UUID(), transcript: String, generatedOutput: String = "", createdAt: Date = .now) {
        self.id = id
        self.transcript = transcript
        self.generatedOutput = generatedOutput
        self.createdAt = createdAt
    }
}

@Model
final class InterviewSession {
    var id: UUID
    var type: String
    var score: Int
    var transcript: String
    var feedback: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        type: String,
        score: Int = 70,
        transcript: String = "",
        feedback: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.type = type
        self.score = score
        self.transcript = transcript
        self.feedback = feedback
        self.createdAt = createdAt
    }
}

@Model
final class Achievement {
    var id: UUID
    var title: String
    var detail: String
    var unlocked: Bool

    init(id: UUID = UUID(), title: String, detail: String, unlocked: Bool = false) {
        self.id = id
        self.title = title
        self.detail = detail
        self.unlocked = unlocked
    }
}

@Model
final class SubscriptionState {
    var id: UUID
    var plan: String
    var isActive: Bool

    init(id: UUID = UUID(), plan: String = SubscriptionPlan.free.rawValue, isActive: Bool = false) {
        self.id = id
        self.plan = plan
        self.isActive = isActive
    }
}

struct JobAnalysis: Identifiable {
    let id = UUID()
    let behaviours: [String]
    let strengths: [String]
    let essentialCriteria: [String]
    let desirableCriteria: [String]
    let competencies: [String]
    let interviewRisks: [String]
    let scoringOpportunities: [String]
    let strategy: String
    let roadmap: [String]
}

struct STARGenerationResult {
    let polishedAnswer: String
    let successProfileAlignment: String
    let interviewVersion: String
    let applicationVersion: String
    let strongerExamples: [String]
}

struct InterviewFeedback {
    let score: Int
    let starScore: Int
    let clarity: String
    let structure: String
    let recommendations: [String]
}

struct CareerRoadmap {
    let promotionPathway: String
    let skillGaps: [String]
    let competencyGaps: [String]
    let nextRoles: [String]
    let developmentPlan: [String]
}

struct ComplianceNotice {
    static let text = "Review before submission. Interview outcomes are not guaranteed. You are responsible for final applications."
}
