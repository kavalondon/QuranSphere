//
//  DuaDetailView.swift
//  QuranSphere
//
//  Created by Khaver Javed on 05/08/2026.
//

import SwiftUI

struct DuaDetailView: View {
    let dua: DailyDua
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("arabicFont") private var arabicFont: String = "Amiri"
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let backgroundColor = Color(red: 0.97, green: 0.97, blue: 0.96)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .trailing, spacing: 32) {
                
                // Arabic Text
                Text(dua.arabic)
                    .font(.custom(arabicFont, size: 38))
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(12)
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: 28) {
                    
                    // Transliteration Section
                    DetailSection(
                        icon: "character.book.closed.fill",
                        title: "Transliteration",
                        content: dua.transliteration,
                        sageGreen: sageGreen
                    )
                    
                    // Translation Section
                    DetailSection(
                        icon: "globe",
                        title: "Translation",
                        content: dua.translation,
                        sageGreen: sageGreen
                    )
                    
                    // Benefit Section
                    DetailSection(
                        icon: "book.pages.fill",
                        title: "Benefit",
                        content: dua.benefit,
                        sageGreen: sageGreen
                    )
                    
                    // Reference Section
                    DetailSection(
                        icon: "link",
                        title: "Reference",
                        content: dua.reference,
                        sageGreen: sageGreen
                    )
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
        }
        .background(isDarkMode ? Color.black : backgroundColor)
        .navigationTitle(dua.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Reusable Subview for Data Blocks
struct DetailSection: View {
    let icon: String
    let title: String
    let content: String
    let sageGreen: Color
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(sageGreen.opacity(0.8))
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(sageGreen.opacity(0.8))
                    .fontWeight(.semibold)
            }
            
            Text(content)
                .font(.system(.body, design: .serif))
                .foregroundColor(isDarkMode ? .white.opacity(0.9) : Color(red: 0.2, green: 0.2, blue: 0.2))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
