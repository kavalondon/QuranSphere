//
//  GuidesSectionView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 23/07/2026.
//

import SwiftUI

// 🌟 MOVED: The data model now lives here
struct GuideCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct GuidesSectionView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // 🌟 MOVED: Add or remove guides strictly from this array now!
    // 🌟 CHANGED: All cards now use the exact same primary green color
    let howToGuides = [
        GuideCard(title: "Prayer Guide", subtitle: "The Second Pillar", icon: "book.pages.fill", color: Color(red: 0.38, green: 0.48, blue: 0.43)),
        GuideCard(title: "Tahajjud", subtitle: "The Night Prayer", icon: "moon.stars.fill", color: Color(red: 0.38, green: 0.48, blue: 0.43)),
        GuideCard(title: "Istikhara", subtitle: "Seeking Guidance", icon: "hands.sparkles.fill", color: Color(red: 0.38, green: 0.48, blue: 0.43))
        //GuideCard(title: "Dhikr", subtitle: "After the prayer", icon: "sparkles", color: Color(red: 0.38, green: 0.48, blue: 0.43))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Guides & Learning")
                .font(.system(.subheadline, design: .serif)).bold()
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .padding(.horizontal, 24)
            
            // 🌟 CHANGED: Now uses the homepage's 2-column grid layout
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(howToGuides) { guide in
                    // 🌟 ROUTING LOGIC: Directs the specific card to its specific view (Preserved)
                    if guide.title == "Tahajjud" {
                        NavigationLink(destination: TahajjudGuideView()) {
                            howToCard(guide: guide)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if guide.title == "Prayer Guide" {
                        NavigationLink(destination: PrayerGuideListView()) {
                            howToCard(guide: guide)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else if guide.title == "Istikhara" {
                        NavigationLink(destination: IstikharaGuideView()) {
                            howToCard(guide: guide)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        NavigationLink(destination: Text("\(guide.title) Guide Coming Soon")) {
                            howToCard(guide: guide)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // 🌟 CHANGED: UI styled to match the homepage cards (solid background, white text)
    private func howToCard(guide: GuideCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: guide.icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(guide.title)
                    .font(.system(.body, design: .serif)).bold()
                    .foregroundColor(.white)
                
                Text(guide.subtitle)
                    .font(.system(size: 11, design: .serif))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 110, maxHeight: 110)
        .contentShape(Rectangle())
        .background(guide.color) // Uses the specific color from your array
        .cornerRadius(16)
    }
}
