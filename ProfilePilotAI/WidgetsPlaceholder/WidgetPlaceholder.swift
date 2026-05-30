import Foundation

struct ProfilePilotWidgetPlaceholder {
    enum Kind: String, CaseIterable {
        case interviewCountdown
        case applicationTracker
        case dailyQuestion
        case confidenceScore
    }

    let kind: Kind
    let title: String
    let value: String

    static let samples = [
        ProfilePilotWidgetPlaceholder(kind: .interviewCountdown, title: "Interview Countdown", value: "3 days"),
        ProfilePilotWidgetPlaceholder(kind: .applicationTracker, title: "Application Tracker", value: "2 active"),
        ProfilePilotWidgetPlaceholder(kind: .dailyQuestion, title: "Daily Question", value: "Tell me about a decision"),
        ProfilePilotWidgetPlaceholder(kind: .confidenceScore, title: "Confidence Score", value: "82%")
    ]
}
