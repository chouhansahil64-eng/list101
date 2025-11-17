//
//  new_1App.swift
//  new 1
//
//  Created by Sahil Chouhan on 12/11/25.
//

import SwiftUI

@main
struct new_1App: App {
    @StateObject private var appLanguage = AppLanguage(defaultIdentifier: "en")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appLanguage)
                .environment(\.locale, appLanguage.locale)
        }
    }
}
