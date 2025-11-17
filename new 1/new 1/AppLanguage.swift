import SwiftUI
import Combine

final class AppLanguage: ObservableObject {
    @Published var locale: Locale

    init(defaultIdentifier: String = "en") {
        self.locale = Locale(identifier: defaultIdentifier)
    }

    func set(_ identifier: String) {
        guard locale.identifier != identifier else { return }
        locale = Locale(identifier: identifier)
    }

    func toggleEnglishItalian() {
        if locale.identifier.hasPrefix("it") {
            set("en")
        } else {
            set("it")
        }
    }

    var displayCode: String {
        locale.identifier.hasPrefix("it") ? "IT" : "EN"
    }
}
