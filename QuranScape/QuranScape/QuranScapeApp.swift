//
//  QuranScapeApp.swift
//  QuranScape
//
//  Created by Khaver Javed on 15/07/2026.
//

import SwiftUI

@main
struct QuranScapeApp: App {
    // 1. Initialize the manager here so it stays alive for the whole app
    @StateObject private var quranManager = LocalQuranManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 2. Inject it into the environment for all sub-views to access
                .environmentObject(quranManager)
        }
    }
}
