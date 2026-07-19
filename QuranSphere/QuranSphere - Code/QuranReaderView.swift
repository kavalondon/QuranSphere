import SwiftUI

struct QuranReaderView: View {
    let surahNumber: Int
    let surahName: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var quranManager: LocalQuranManager
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    @AppStorage("lastReadVerse") private var lastReadVerse = 1
    @AppStorage("readingProgress") private var readingProgress: Double = 0.0
    
    @State private var surahVerses: [JSONVerse] = []
    @State private var currentVerseIndex: Int = 0
    
    // Core brand color
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    var body: some View {
        ZStack {
            // MARK: - Background
            Group {
                if isDarkMode {
                    Color(red: 0.10, green: 0.12, blue: 0.11)
                } else {
                    Color(red: 0.97, green: 0.97, blue: 0.95)
                }
            }
            .ignoresSafeArea()
            
            if surahVerses.isEmpty {
                ProgressView()
                    .tint(sageGreen)
            } else {
                VStack(spacing: 0) {
                    
                    // MARK: - Top Custom Header & Progress
                    headerSection
                    
                    Spacer()
                    
                    // MARK: - The Main Verse Card (Quranly Style)
                    verseCard(verse: surahVerses[currentVerseIndex])
                    
                    // MARK: - Translation Text Below Card
                    Text(surahVerses[currentVerseIndex].translation)
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    Spacer()
                    
                    // MARK: - Bottom Navigation Controls
                    bottomControls
                }
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true) // Hide default nav to use our custom top bar
        .onAppear {
            loadVerses()
        }
    }
    
    // MARK: - UI Sections
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(12)
                        .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Custom Stats Pill (Placeholder for gamification later)
                HStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(sageGreen)
                    Text("Daily Reading")
                        .font(.system(.subheadline, design: .rounded)).bold()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .clipShape(Capsule())
                
                Spacer()
                
                Button(action: { /* Settings Action */ }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // Progress Bar Info
            let totalVerses = surahVerses.count
            let currentVerseNum = currentVerseIndex + 1
            let progress = Double(currentVerseNum) / Double(totalVerses)
            
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: sageGreen))
                    .padding(.horizontal, 24)
                
                HStack {
                    Text("\(currentVerseNum) / \(totalVerses)")
                        .font(.system(.caption, design: .rounded)).bold()
                    Spacer()
                    Text("\(totalVerses - currentVerseNum) Verses left")
                        .font(.system(.caption, design: .rounded))
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(.caption, design: .rounded)).bold()
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func verseCard(verse: JSONVerse) -> some View {
        VStack(spacing: 24) {
            // Card Top Toolbar
            HStack {
                Button(action: { /* Play Audio */ }) {
                    Image(systemName: "play.fill")
                        .foregroundColor(sageGreen)
                        .padding(10)
                        .background(sageGreen.opacity(0.15))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("\(surahNumber). \(surahName)")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(isDarkMode ? .white : .black)
                    Text("\(verse.verseNumber) / \(surahVerses.count)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { /* Bookmark Action */ }) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            
            // Central Arabic Text
            Text(verse.text)
                .font(.system(size: 38, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(16)
                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                .frame(maxWidth: .infinity, minHeight: 150)
                .padding(.vertical, 16)
            
            // Card Bottom Toolbar
            HStack {
                Button(action: { /* Share Action */ }) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .foregroundColor(.gray)
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(24)
        .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 24)
    }
    
    private var bottomControls: some View {
        HStack {
            // Previous Verse Button
            Button(action: {
                if currentVerseIndex > 0 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentVerseIndex -= 1
                        saveProgress()
                    }
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(currentVerseIndex > 0 ? (isDarkMode ? .white : .black) : .gray.opacity(0.3))
                    .frame(width: 60, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(currentVerseIndex > 0 ? .gray.opacity(0.3) : .clear, lineWidth: 1)
                    )
            }
            .disabled(currentVerseIndex == 0)
            
            Spacer()
            
            // "I'm Done" Main Button
            Button(action: { dismiss() }) {
                Text("I'm Done")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(isDarkMode ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isDarkMode ? Color.white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    .cornerRadius(25)
            }
            
            Spacer()
            
            // Next Verse Button
            Button(action: {
                if currentVerseIndex < surahVerses.count - 1 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentVerseIndex += 1
                        saveProgress()
                    }
                }
            }) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(currentVerseIndex < surahVerses.count - 1 ? (isDarkMode ? .black : .white) : .gray.opacity(0.3))
                    .frame(width: 60, height: 50)
                    .background(currentVerseIndex < surahVerses.count - 1 ? sageGreen : sageGreen.opacity(0.2))
                    .cornerRadius(25)
            }
            .disabled(currentVerseIndex == surahVerses.count - 1)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Logic Methods
    
    private func loadVerses() {
        // Load verses for this Surah
        let filtered = quranManager.verses.filter { $0.surahNumber == surahNumber }
        surahVerses = filtered.sorted { $0.verseNumber < $1.verseNumber }
        
        // If the user was previously reading this Surah, jump to their last verse
        if lastReadSurah == surahNumber {
            if let index = surahVerses.firstIndex(where: { $0.verseNumber == lastReadVerse }) {
                currentVerseIndex = index
            }
        } else {
            currentVerseIndex = 0
        }
    }
    
    private func saveProgress() {
        guard !surahVerses.isEmpty else { return }
        lastReadSurah = surahNumber
        lastReadSurahName = surahName
        lastReadVerse = surahVerses[currentVerseIndex].verseNumber
        
        // Update global reading progress (total quran progress placeholder calculation)
        let totalVersesInQuran = 6236.0
        readingProgress = min(readingProgress + (1.0 / totalVersesInQuran), 1.0)
    }
}
