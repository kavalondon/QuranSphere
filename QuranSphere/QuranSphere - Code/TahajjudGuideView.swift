import SwiftUI

struct TahajjudGuideView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var expandedImage: String? = nil
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var bgColor: Color {
        isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95)
    }
    
    var cardColor: Color {
        isDarkMode ? Color.white.opacity(0.06) : Color.white
    }
    
    var textColor: Color {
        isDarkMode ? .white.opacity(0.9) : Color(red: 0.18, green: 0.23, blue: 0.20)
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    introSection
                    whenToPraySection
                    stepByStepSection
                    benefitsSection
                }
                .padding(24)
            }
            
            // Full-Screen Image Overlay
            if let imageName = expandedImage {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                expandedImage = nil
                            }
                        }
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(24)
                        .shadow(radius: 20)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                expandedImage = nil
                            }
                        }
                }
                .zIndex(1)
            }
        }
        .navigationTitle("Tahajjud Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 42))
                .foregroundColor(accentGold)
                .shadow(color: accentGold.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("How to Pray Tahajjud")
                .font(.system(.title2, design: .serif)).bold()
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
            
            Text("A highly recommended voluntary night prayer to seek forgiveness and closeness to Allah.")
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
    
    private var introSection: some View {
        quranQuoteCard(
            verse: "And during a part of the night, pray Tahajjud beyond what is incumbent on you; maybe your Lord will raise you to a position of great glory.",
            reference: "Qur'an 17:79",
            color: sageGreen
        )
    }
    
    private var whenToPraySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When to Pray")
                .font(.system(.title3, design: .serif)).bold()
                .foregroundColor(accentGold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Anytime after Isha and before Fajr. The most rewarding time is the last third of the night.")
                .font(.system(.body, design: .serif))
                .foregroundColor(textColor)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            hadithQuoteCard(
                text: "Our Lord descends every night to the lowest heaven when one-third of the night remains, and He says: ‘Who will call upon Me, that I may answer him?...’",
                reference: "Sahih al-Bukhari & Muslim",
                color: accentGold
            )
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentGold.opacity(0.3), lineWidth: 1))
    }
    
    private var stepByStepSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How to Pray (2 Rakahs)")
                .font(.system(.title3, design: .serif)).bold()
                .foregroundColor(sageGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                stepCard(step: 1, title: "Intention", desc: "Face the Qibla and make a sincere intention to pray Tahajjud.", imageName: "salah-step-01-niyyah")
                stepCard(step: 2, title: "Takbeer", desc: "Raise your hands and say “Allahu Akbar”.", imageName: "salah-step-02-takbeer")
                stepCard(step: 3, title: "Recitation", desc: "Recite Surah Al-Fatihah, followed by another Surah.", imageName: "salah-step-03-qiyam")
                stepCard(step: 4, title: "Ruku (Bowing)", desc: "Bow saying “Allahu Akbar”. Say “Subhana Rabbiy-al-Adheem” 3 times.", imageName: "salah-step-04-ruku")
                stepCard(step: 5, title: "Rising", desc: "Stand saying “Sami’ Allahu liman hamidah” then “Rabbana lakal hamd”.", imageName: "salah-step-05-qawma")
                stepCard(step: 6, title: "Sujood (Prostration)", desc: "Prostrate saying “Allahu Akbar”. Say “Subhaana Rabbiy-al-A‘laa” 3 times.", imageName: "salah-step-06-sujood")
                stepCard(step: 7, title: "Sitting", desc: "Sit up saying “Allahu Akbar”, then perform a second Sujood. Stand up to repeat steps 3-7 for the second rakah.", imageName: "salah-step-07-jalsa")
                stepCard(step: 8, title: "Tashahhud", desc: "After the second rakah, sit to recite Tashahhud and Salawat.", imageName: "salah-step-08-tashahhud")
                stepCard(step: 9, title: "Tasleem", desc: "Turn your head right then left, saying “Assalamu alaikum wa rahmatullah”. Conclude with heartfelt Dua.", imageName: "salah-step-09-salaam")
            }
        }
    }
    
    private var benefitsSection: some View {
        hadithQuoteCard(
            text: "The most beloved deeds to Allah are those that are consistent, even if they are small.",
            reference: "Sahih al-Bukhari & Muslim",
            color: sageGreen
        )
    }
    
    // MARK: - Reusable UI Components
    
    private func quranQuoteCard(verse: String, reference: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "book.fill")
                    .foregroundColor(color)
                    .font(.system(size: 14))
                Text("Al-Qur'an")
                    .font(.system(.caption, design: .monospaced)).bold()
                    .foregroundColor(color)
            }
            Text("“\(verse)”")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundColor(textColor)
                .lineSpacing(6)
            Text(reference)
                .font(.system(.caption, design: .serif))
                .foregroundColor(.gray)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func hadithQuoteCard(text: String, reference: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "quote.opening")
                    .foregroundColor(color)
                    .font(.system(size: 14))
                Text("Hadith")
                    .font(.system(.caption, design: .monospaced)).bold()
                    .foregroundColor(color)
            }
            Text("“\(text)”")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundColor(textColor)
                .lineSpacing(6)
            Text(reference)
                .font(.system(.caption, design: .serif))
                .foregroundColor(.gray)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func stepCard(step: Int, title: String, desc: String, imageName: String) -> some View {
        let themeColor = step % 2 == 0 ? accentGold : sageGreen
        
        return HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeColor)
                    .frame(width: 32, height: 32)
                Text("\(step)")
                    .font(.system(.headline, design: .rounded)).bold()
                    .foregroundColor(.white)
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .serif)).bold()
                        .foregroundColor(textColor)
                    Text(desc)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray)
                        .lineSpacing(4)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDarkMode ? themeColor.opacity(0.15) : themeColor.opacity(0.08))
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 140)
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeColor.opacity(isDarkMode ? 0.2 : 0.15), lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        expandedImage = imageName
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeColor.opacity(0.3), lineWidth: 1)
        )
    }
}
