import SwiftUI
import Combine

final class ShakeManager: ObservableObject {
    // An incrementing token that views observe to trigger animations.
    @Published var shakeToken: Int = 0

    func triggerShake() {
        // Increment to notify observers
        shakeToken &+= 1
    }
}
