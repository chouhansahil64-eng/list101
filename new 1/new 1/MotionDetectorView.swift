import UIKit
import SwiftUI

// A transparent UIView that becomes first responder and listens for motion (shake) events.
final class MotionDetectorUIView: UIView {
    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        // Ensure we can receive motion events
        DispatchQueue.main.async { [weak self] in
            _ = self?.becomeFirstResponder()
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
        super.motionEnded(motion, with: event)
    }
}

struct MotionDetectorView: UIViewRepresentable {
    let onShake: () -> Void

    func makeUIView(context: Context) -> MotionDetectorUIView {
        let v = MotionDetectorUIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        v.onShake = onShake
        return v
    }

    func updateUIView(_ uiView: MotionDetectorUIView, context: Context) { }
}
