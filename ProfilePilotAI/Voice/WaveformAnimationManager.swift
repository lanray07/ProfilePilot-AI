import Foundation
import SwiftUI

@MainActor
final class WaveformAnimationManager: ObservableObject {
    @Published var levels: [CGFloat] = Array(repeating: 0.18, count: 28)
    private var timer: Timer?

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 0.16, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.levels = (0..<28).map { index in
                    let base = CGFloat.random(in: 0.18...0.95)
                    return index.isMultiple(of: 4) ? min(1, base + 0.08) : base
                }
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        levels = Array(repeating: 0.18, count: 28)
    }
}
