import SwiftData
import SwiftUI

@main
struct ProfilePilotAIApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: UserProfile.self,
                JobApplication.self,
                STARExample.self,
                VoiceTranscript.self,
                InterviewSession.self,
                Achievement.self,
                SubscriptionState.self
            )
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
