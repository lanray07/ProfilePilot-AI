import AVFoundation
import Foundation

@MainActor
final class VoiceRecordingService: ObservableObject {
    @Published var isRecording = false
    @Published var permissionGranted = false

    func requestPermission() async {
        permissionGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func toggle() {
        isRecording.toggle()
    }
}
