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
    let howToGuides = [
        GuideCard(title: "Prayer Guide", subtitle: "The Second Pillar", icon: "book.pages.fill", color: Color(red: 0.83, green: 0.67, blue: 0.51)),
        GuideCard(title: "Tahajjud", subtitle: "The Night Prayer", icon: "moon.stars.fill", color: Color(red: 0.38, green: 0.48, blue: 0.43)),
        //GuideCard(title: "Making Dua", subtitle: "Etiquette & Sunnah", icon: "hands.sparkles.fill", color: Color(red: 0.83, green: 0.67, blue: 0.51)),
        //GuideCard(title: "Dhikr", subtitle: "After the prayer", icon: "sparkles", color: Color(red: 0.52, green: 0.61, blue: 0.56))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Guides & Learning")
                .font(.system(.subheadline, design: .serif)).bold()
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(howToGuides) { guide in
                        // 🌟 ROUTING LOGIC: Directs the specific card to its specific view
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
    }
    
    // 🌟 MOVED: The specific UI styling for the card
    private func howToCard(guide: GuideCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: guide.icon)
                .font(.title2)
                .foregroundColor(guide.color)
                .padding(12)
                .background(guide.color.opacity(0.15))
                .clipShape(Circle())
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(guide.title)
                    .font(.system(.headline, design: .serif)).bold()
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                Text(guide.subtitle)
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(width: 160, height: 140, alignment: .leading)
        .contentShape(Rectangle())
        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}
