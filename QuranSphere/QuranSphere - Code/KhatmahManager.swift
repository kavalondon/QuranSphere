//
//  KhatmahManager.swift
//  QuranSphere
//

import Foundation
import SwiftUI
internal import Combine

class KhatmahManager: ObservableObject {
    static let shared = KhatmahManager()
    
    // MARK: - Local Storage Properties
    @AppStorage("isKhatmahActive") var isKhatmahActive: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("khatmahDaysTarget") var khatmahDaysTarget: Int = 30 {
        didSet { objectWillChange.send() }
    }
    @AppStorage("khatmahStartDate") var khatmahStartDate: Double = Date().timeIntervalSince1970 {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - Helper Computed Properties
    
    var targetEndDate: Date {
        let startDate = Date(timeIntervalSince1970: khatmahStartDate)
        return Calendar.current.date(byAdding: .day, value: khatmahDaysTarget, to: startDate) ?? startDate
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        if now >= targetEndDate { return 0 }
        let components = calendar.dateComponents([.day], from: now, to: targetEndDate)
        return max(0, components.day ?? 0)
    }
    
    // MARK: - Actions
    
    func startKhatmah(days: Int) {
        self.khatmahDaysTarget = days
        self.khatmahStartDate = Date().timeIntervalSince1970
        self.isKhatmahActive = true
    }
    
    func resetKhatmah() {
        self.isKhatmahActive = false
        self.khatmahDaysTarget = 30
        self.khatmahStartDate = Date().timeIntervalSince1970
    }
}
