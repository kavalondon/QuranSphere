//
//  QuranSphereApp.swift
//  QuranSphere
//
//  Created by Khaver Javed on 15/07/2026.
//

import SwiftUI

@main
struct QuranSphereApp: App {
    @StateObject private var quranManager = LocalQuranManager()
    @StateObject private var khatmahManager = KhatmahManager.shared // Add this line
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quranManager)
                .environmentObject(khatmahManager) // Inject it here
        }
    }
}
