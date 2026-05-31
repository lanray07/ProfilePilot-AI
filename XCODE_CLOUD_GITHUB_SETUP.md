# Xcode Cloud GitHub Setup

Use this repository as the source for Xcode Cloud in App Store Connect.

## Repository

- GitHub: `https://github.com/lanray07/ProfilePilot-AI`
- Xcode project: `ProfilePilotAI.xcodeproj`
- Shared scheme: `ProfilePilot AI`
- App target: `ProfilePilot AI`
- Bundle identifier: `com.profilepilotai.app`
- Version: `1.0`
- Build: `4`

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

## GitHub Actions App Store Upload

The repository also includes `.github/workflows/ios-build.yml`. The workflow uses GitHub's `macos-26` hosted runner so App Store uploads are built with the iOS 26 SDK required by App Store Connect.

For simulator validation, the workflow runs automatically on pushes to `main`.

For an App Store Connect upload, add these GitHub repository secrets, then run the workflow manually and set `upload_to_app_store_connect` to `true`.

App Store Connect API secrets:

- `APPLE_TEAM_ID`: Apple Developer Program Team ID.
- `APPSTORE_KEY_ID`: App Store Connect API key ID.
- `APPSTORE_ISSUER_ID`: App Store Connect API issuer ID.
- `APPSTORE_PRIVATE_KEY`: Full `.p8` private key contents.

Accepted aliases include `TEAM_ID`, `APPSTORE_API_KEY_ID`, `APP_STORE_CONNECT_API_KEY_ID`, `ASC_API_KEY_ID`, `KEY_ID`, `APPSTORE_API_ISSUER_ID`, `APP_STORE_CONNECT_API_ISSUER_ID`, `ASC_API_ISSUER_ID`, `ISSUER_ID`, `APPSTORE_API_PRIVATE_KEY`, `APP_STORE_CONNECT_API_PRIVATE_KEY`, `ASC_API_PRIVATE_KEY`, and `PRIVATE_KEY`.

Distribution signing:

The GitHub Actions upload job first tries to use the App Store Connect API key to create a short-lived Apple Distribution certificate and an App Store provisioning profile for `com.profilepilotai.app`. This avoids storing certificate files in GitHub Secrets.

If Apple rejects API certificate/profile creation for the account, add these fallback secrets:

- `IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64`: Base64 text for an Apple Distribution `.p12` certificate.
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`: Password for the `.p12` certificate, if one was set.
- `IOS_APP_STORE_PROVISIONING_PROFILE_BASE64`: Base64 text for the App Store provisioning profile for `com.profilepilotai.app`.
- `IOS_PROVISIONING_PROFILE_NAME`: Optional override for the provisioning profile name. If omitted, the workflow reads the name from the profile.

Accepted aliases include `IOS_CERTIFICATE_P12_BASE64`, `BUILD_CERTIFICATE_BASE64`, `IOS_CERTIFICATE_PASSWORD`, `P12_PASSWORD`, `IOS_PROVISIONING_PROFILE_BASE64`, `BUILD_PROVISION_PROFILE_BASE64`, and `PROVISIONING_PROFILE_NAME`.

To create the base64 values on macOS:

```sh
base64 -i distribution.p12 | pbcopy
base64 -i ProfilePilot_AppStore.mobileprovision | pbcopy
```

The manual upload job imports the distribution certificate into a temporary keychain, installs the App Store provisioning profile, archives the `ProfilePilot AI` shared scheme with manual signing, exports an App Store Connect IPA, stores the IPA as a GitHub artifact, and uploads it to App Store Connect.
