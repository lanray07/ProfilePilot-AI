import SwiftData
import SwiftUI

struct VoiceCoachingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var viewModel: AppViewModel
    @StateObject private var speech = SpeechRecognitionService()
    @StateObject private var waveform = WaveformAnimationManager()
    @State private var module = "STAR Example"

    private let modules = ["STAR Example", "Competency Example", "Interview Answer", "Application Content"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Voice Coaching")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PremiumTheme.ink)
                Picker("Module", selection: $module) {
                    ForEach(modules, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
                VoiceWaveformView(levels: waveform.levels, isActive: speech.isTranscribing)
                PremiumButton(title: speech.isTranscribing ? "Stop Recording" : "Start Voice Capture", icon: speech.isTranscribing ? "stop.fill" : "mic.fill") {
                    Task {
                        if speech.isTranscribing {
                            speech.stop()
                            waveform.stop()
                        } else {
                            await speech.requestAuthorization()
                            try? speech.start()
                            waveform.start()
                        }
                    }
                }
                PremiumDashboardCard(title: "Live Transcript", subtitle: "Editable after recording", icon: "text.bubble") {
                    TextEditor(text: $speech.transcript)
                        .frame(minHeight: 150)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(PremiumTheme.ink)
                }
                PremiumButton(title: "Generate Coaching Output", icon: "sparkles") {
                    Task { await viewModel.generateFromVoice(transcript: speech.transcript, module: module) }
                }
                if !viewModel.generatedVoiceOutput.isEmpty {
                    PremiumDashboardCard(title: "AI Draft", subtitle: "Confidence analysis placeholder included", icon: "waveform.badge.magnifyingglass") {
                        Text(viewModel.generatedVoiceOutput)
                            .foregroundStyle(PremiumTheme.ink)
                        PremiumButton(title: "Save Transcript", icon: "tray.and.arrow.down") {
                            modelContext.insert(VoiceTranscript(transcript: speech.transcript, generatedOutput: viewModel.generatedVoiceOutput))
                        }
                    }
                }
            }
            .padding()
        }
        .background(PremiumBackground())
        .navigationTitle("Voice")
    }
}
