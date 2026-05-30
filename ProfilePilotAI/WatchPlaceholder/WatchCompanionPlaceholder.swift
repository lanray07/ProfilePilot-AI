import Foundation

struct WatchCompanionPlaceholder {
    enum Capability: String, CaseIterable {
        case reminders
        case voiceNotes
        case interviewCountdown
        case confidencePrompts
    }

    let capabilities = Capability.allCases
}
