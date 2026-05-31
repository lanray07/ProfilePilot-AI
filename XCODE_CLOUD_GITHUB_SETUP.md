# Xcode Cloud GitHub Setup

Use this repository as the source for Xcode Cloud in App Store Connect.

## Repository

- GitHub: `https://github.com/lanray07/ProfilePilot-AI`
- Xcode project: `ProfilePilotAI.xcodeproj`
- Shared scheme: `ProfilePilot AI`
- App target: `ProfilePilot AI`
- Bundle identifier: `com.profilepilot.ai`
- Version: `1.0`
- Build: `1`

## App Store Connect Workflow

1. Open App Store Connect > ProfilePilot AI > Xcode Cloud.
2. Create a workflow from GitHub.
3. Select `lanray07/ProfilePilot-AI`.
4. Select project `ProfilePilotAI.xcodeproj`.
5. Select shared scheme `ProfilePilot AI`.
6. Use the Release configuration for archive builds.
7. Enable automatic signing for the Apple Developer team that owns the App Store app.
8. After the workflow uploads a build, select that build on iOS App Version 1.0 before submitting for review.

## Notes

- The app supports iPhone and iPad through `TARGETED_DEVICE_FAMILY = 1,2`.
- Microphone and speech recognition usage strings are already in `Info.plist`.
- Subscription product IDs are prepared in App Store Connect and referenced in the repo metadata.
