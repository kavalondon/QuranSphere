import SwiftUI
import AVFoundation

// Struct to cache page data so we aren't calculating it on every frame drop
struct MushafPage: Identifiable {
    let id: Int
    let text: String
    let firstVerseIndex: Int
}

struct QuranReaderView: View {
    let surahNumber: Int
    let surahName: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var quranManager: LocalQuranManager
    
    // Core Progress Trackers
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isFullPageMode") private var isFullPageMode = false
    @AppStorage("lastReadSurah") private var lastReadSurah = 1
    @AppStorage("lastReadSurahName") private var lastReadSurahName = "Al-Fatihah"
    @AppStorage("lastReadVerse") private var lastReadVerse = 1
    @AppStorage("readingProgress") private var readingProgress: Double = 0.0
    
    // Feature Storage: Bookmarks & Favorites
    @AppStorage("bookmarkedVerseIDs") private var bookmarkedVerseIDsStr: String = ""
    @AppStorage("favoriteSurahIDs") private var favoriteSurahIDsStr: String = ""
    
    // Typography AppStorage variables
    @AppStorage("arabicFont") private var arabicFont = "KFGQPCUthmanTahaNaskh"
    @AppStorage("preferredScript") private var preferredScript = "uthmani"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 38.0
    @AppStorage("translationFontSize") private var translationFontSize: Double = 20.0
    
    @State private var surahVerses: [JSONVerse] = []
    @State private var mushafPages: [MushafPage] = [] // Cached pages
    @State private var currentVerseIndex: Int = 0
    @State private var currentPageIndex: Int = 0
    @State private var showSettings = false
    
    // Audio Player State
    @State private var audioPlayer: AVPlayer?
    @State private var isPlayingAudio = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundLayer
            
            if surahVerses.isEmpty || mushafPages.isEmpty {
                ProgressView()
                    .tint(sageGreen)
            } else {
                mainContentLayer
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadVerses() }
        .onChange(of: isFullPageMode) { _ in
            currentPageIndex = getPageIndex(for: currentVerseIndex)
        }
        .onChange(of: preferredScript) { _ in
            buildPages()
        }
        .onChange(of: arabicFontSize) { _ in
            buildPages()
            currentPageIndex = getPageIndex(for: currentVerseIndex)
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
            handleAudioCompletion()
        }
        .sheet(isPresented: $showSettings) {
            ReaderSettingsSheet()
        }
    }
    
    // MARK: - Separated Views
    private var backgroundLayer: some View {
        Group {
            if isDarkMode {
                Color(red: 0.10, green: 0.12, blue: 0.11)
            } else {
                Color(red: 0.97, green: 0.97, blue: 0.95)
            }
        }
        .ignoresSafeArea()
    }
    
    private var mainContentLayer: some View {
        VStack(spacing: 0) {
            headerSection
            
            if isFullPageMode {
                fullPageView
            } else {
                verseByVerseView
            }
            
            bottomControls
        }
        .padding(.bottom, 16)
    }
    
    private var fullPageView: some View {
        TabView(selection: $currentPageIndex) {
            ForEach(mushafPages) { page in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Surah \(surahName)")
                            Spacer()
                            Text("Page \(page.id + 1)")
                        }
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                        .padding(.bottom, 12)
                        
                        Divider()
                            .background(isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                            .padding(.bottom, 16)
                        
                        Text(page.text)
                            .font(.custom(arabicFont, size: arabicFontSize))
                            .multilineTextAlignment(.center)
                            .lineSpacing(20)
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .padding(24)
                    .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.96))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.85, green: 0.81, blue: 0.73).opacity(isDarkMode ? 0.2 : 1.0), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(isDarkMode ? 0.4 : 0.06), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .tag(page.id)
                .environment(\.layoutDirection, .leftToRight)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .environment(\.layoutDirection, .rightToLeft)
        .onChange(of: currentPageIndex) { newPage in
            if let targetPage = mushafPages.first(where: { $0.id == newPage }) {
                currentVerseIndex = targetPage.firstVerseIndex
                saveProgress()
            }
        }
    }
    
    private var verseByVerseView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer().frame(height: 12)
                
                VStack(spacing: 24) {
                    verseHeader
                    
                    let verse = surahVerses[currentVerseIndex]
                    let fullArabicText = "\(verse.arabicText(for: preferredScript)) \u{06DD}\(getArabicNumeral(for: verse.verseNumber))"
                    
                    Text(fullArabicText)
                        .font(.custom(arabicFont, size: arabicFontSize))
                        .multilineTextAlignment(.center)
                        .lineSpacing(16)
                        .baselineOffset(10)
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .padding(.vertical, 8)
                        .id(arabicFont + preferredScript + "\(verse.id)")
                        .onAppear {
                            GamificationManager.shared.logVerseRead(arabicText: verse.arabicText(for: preferredScript))
                        }
                    
                    Divider()
                        .opacity(0.4)
                        .padding(.horizontal, 12)
                    
                    Text(cleanTranslationText(verse.translation))
                        .font(.system(size: translationFontSize, weight: .medium, design: .serif))
                        .foregroundColor(isDarkMode ? .white.opacity(0.8) : Color(red: 0.18, green: 0.23, blue: 0.20))
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    verseFooter
                }
                .padding(24)
                .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.04), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
            }
        }
    }
    
    // MARK: - Components
    private var verseHeader: some View {
        let verse = surahVerses[currentVerseIndex]
        let isBookmarked = bookmarkedIDs.contains(verse.id)
        
        return HStack {
            Button(action: {
                triggerHaptic()
                toggleAudio(for: verse)
            }) {
                Image(systemName: isPlayingAudio ? "stop.fill" : "play.fill")
                    .foregroundColor(sageGreen)
                    .padding(10)
                    .background(sageGreen.opacity(0.15))
                    .clipShape(Circle())
                    .animation(nil, value: isPlayingAudio)
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
            
            Button(action: {
                triggerHaptic()
                toggleBookmark(for: verse.id)
            }) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundColor(isBookmarked ? sageGreen : .gray)
            }
        }
    }
    
    private var verseFooter: some View {
        let verse = surahVerses[currentVerseIndex]
        let shareText = "\(verse.arabicText(for: preferredScript))\n\n\(cleanTranslationText(verse.translation))\n\n— Quran \(surahNumber):\(verse.verseNumber) (\(surahName))"
        
        return HStack {
            ShareLink(item: shareText) {
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Button(action: {
                        triggerHaptic()
                        stopAudio()
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding(10)
                            .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                    
                    if !isFullPageMode {
                        Button(action: {
                            triggerHaptic()
                            restartSurah()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(currentVerseIndex > 0 ? (isDarkMode ? .white : .black) : .gray.opacity(0.3))
                                .padding(10)
                                .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                                .clipShape(Circle())
                        }
                        .disabled(currentVerseIndex == 0)
                    }
                }
                
                Spacer(minLength: 4)
                
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .foregroundColor(sageGreen)
                        .font(.system(size: 14))
                    Text(isFullPageMode ? "Mushaf Mode" : "Daily Reading")
                        .font(.system(.subheadline, design: .rounded)).bold()
                        .lineLimit(1)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .clipShape(Capsule())
                
                Spacer(minLength: 4)
                
                HStack(spacing: 8) {
                    let isFav = favoriteSurahs.contains(surahNumber)
                    Button(action: {
                        triggerHaptic()
                        toggleFavoriteSurah()
                    }) {
                        Image(systemName: isFav ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isFav ? .red : (isDarkMode ? .white : .black))
                            .padding(10)
                            .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        triggerHaptic()
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding(10)
                            .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            if !isFullPageMode {
                let totalVerses = surahVerses.count
                let currentVerseNum = currentVerseIndex + 1
                let progress = Double(currentVerseNum) / Double(max(totalVerses, 1))
                
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: sageGreen))
                        .padding(.horizontal, 24)
                    
                    HStack {
                        Menu {
                            ForEach(0..<totalVerses, id: \.self) { index in
                                Button(action: {
                                    triggerHaptic()
                                    stopAudio()
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        currentVerseIndex = index
                                        saveProgress()
                                    }
                                }) {
                                    Text("Verse \(index + 1)")
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(currentVerseNum) / \(totalVerses)")
                                    .font(.system(.caption, design: .rounded)).bold()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        Text("\(totalVerses - currentVerseNum) Verses left")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(.caption, design: .rounded)).bold()
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                let totalPages = max(1, mushafPages.count)
                let currentPageNum = currentPageIndex + 1
                let progress = Double(currentPageNum) / Double(totalPages)
                
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: sageGreen))
                        .padding(.horizontal, 24)
                    
                    HStack {
                        Menu {
                            ForEach(0..<totalPages, id: \.self) { index in
                                Button(action: {
                                    triggerHaptic()
                                    stopAudio()
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        currentPageIndex = index
                                        if let targetPage = mushafPages.first(where: { $0.id == index }) {
                                            currentVerseIndex = targetPage.firstVerseIndex
                                        }
                                        saveProgress()
                                    }
                                }) {
                                    Text("Page \(index + 1)")
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(currentPageNum) / \(totalPages)")
                                    .font(.system(.caption, design: .rounded)).bold()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        Text("\(totalPages - currentPageNum) Pages left")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(.caption, design: .rounded)).bold()
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
            }
        }
    }
    
    private var bottomControls: some View {
        HStack {
            if !isFullPageMode {
                Button(action: {
                    triggerHaptic()
                    if currentVerseIndex > 0 {
                        stopAudio()
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
            }
            
            Button(action: {
                triggerHaptic()
                stopAudio()
                dismiss()
            }) {
                Text("I'm Done")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(isDarkMode ? .black : .white)
                    .frame(maxWidth: isFullPageMode ? .infinity : .infinity)
                    .frame(height: 50)
                    .background(isDarkMode ? Color.white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    .cornerRadius(25)
            }
            
            if !isFullPageMode {
                Spacer()
                
                Button(action: {
                    triggerHaptic()
                    if currentVerseIndex < surahVerses.count - 1 {
                        stopAudio()
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
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Helper Methods
    private func buildPages() {
        // Dynamically measure device screen
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Let's explicitly calculate safe area and exact padding:
        // Top Header: ~100 | Bottom Bar: ~82 | Card Padding: ~80 | Card Header: ~50 | Safe Area: ~80
        // Total exact overhead is around 392. Using 340 ensures we don't overestimate and cause dead space.
        let verticalOverhead: CGFloat = 340
        let horizontalOverhead: CGFloat = 88
        
        let usableHeight = max(200, screenHeight - verticalOverhead)
        let usableWidth = max(200, screenWidth - horizontalOverhead)
        
        let lineHeight = (arabicFontSize * 1.4) + 20
        let maxLines = max(1, Int(usableHeight / lineHeight))
        
        let avgCharWidth = arabicFontSize * 0.32
        let charsPerLine = max(1, Int(usableWidth / avgCharWidth))
        
        // 90% fill rate to prevent the very last line from clipping bounds
        let maxCharactersPerPage = max(50, Int(Double(maxLines * charsPerLine) * 0.90))
        
        var newPages: [MushafPage] = []
        var currentPageVerses: [JSONVerse] = []
        var currentCharacterCount = 0
        var pageIndex = 0
        
        for verse in surahVerses {
            let textLength = verse.arabicText(for: preferredScript).count
            
            if currentCharacterCount + textLength > maxCharactersPerPage && !currentPageVerses.isEmpty {
                let pageText = generatePageText(for: currentPageVerses)
                let firstVerseIdx = surahVerses.firstIndex(where: { $0.id == currentPageVerses.first!.id }) ?? 0
                
                newPages.append(MushafPage(id: pageIndex, text: pageText, firstVerseIndex: firstVerseIdx))
                
                currentPageVerses = []
                currentCharacterCount = 0
                pageIndex += 1
            }
            
            currentPageVerses.append(verse)
            currentCharacterCount += textLength
        }
        
        if !currentPageVerses.isEmpty {
            let pageText = generatePageText(for: currentPageVerses)
            let firstVerseIdx = surahVerses.firstIndex(where: { $0.id == currentPageVerses.first!.id }) ?? 0
            newPages.append(MushafPage(id: pageIndex, text: pageText, firstVerseIndex: firstVerseIdx))
        }
        
        mushafPages = newPages
    }
    
    private func getPageIndex(for verseIndex: Int) -> Int {
        return mushafPages.last(where: { $0.firstVerseIndex <= verseIndex })?.id ?? 0
    }
    
    private func generatePageText(for verses: [JSONVerse]) -> String {
        verses.map { verse in
            let text = verse.arabicText(for: preferredScript)
            let num = getArabicNumeral(for: verse.verseNumber)
            return "\(text) \u{06DD}\(num) "
        }.joined(separator: " ")
    }
    
    private func cleanTranslationText(_ rawText: String) -> String {
        var text = rawText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "([\\p{L}\\.,])\\d+", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\[\\d+\\]|\\(\\d+\\)|\\b\\d+\\b", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func getArabicNumeral(for number: Int) -> String {
        let arabicDigits = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        return String(number).compactMap { char in
            if let digit = char.wholeNumberValue {
                return arabicDigits[digit]
            }
            return String(char)
        }.joined()
    }
    
    private func handleAudioCompletion() {
        if !isFullPageMode, currentVerseIndex < surahVerses.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentVerseIndex += 1
                saveProgress()
            }
            let nextVerse = surahVerses[currentVerseIndex]
            toggleAudio(for: nextVerse, forcePlay: true)
        } else {
            isPlayingAudio = false
        }
    }
    
    private func loadVerses() {
        let filtered = quranManager.verses.filter { $0.surahNumber == surahNumber }
        surahVerses = filtered.sorted { $0.verseNumber < $1.verseNumber }
        
        buildPages()
        
        if lastReadSurah == surahNumber {
            if let index = surahVerses.firstIndex(where: { $0.verseNumber == lastReadVerse }) {
                currentVerseIndex = index
                currentPageIndex = getPageIndex(for: currentVerseIndex)
            }
        } else {
            currentVerseIndex = 0
            currentPageIndex = 0
        }
    }
    
    private func saveProgress() {
        guard !surahVerses.isEmpty else { return }
        lastReadSurah = surahNumber
        lastReadSurahName = surahName
        lastReadVerse = surahVerses[currentVerseIndex].verseNumber
        
        let totalVersesInQuran = 6236.0
        readingProgress = min(readingProgress + (1.0 / totalVersesInQuran), 1.0)
    }
    
    private func restartSurah() {
        if currentVerseIndex > 0 {
            stopAudio()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentVerseIndex = 0
                currentPageIndex = 0
                saveProgress()
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func toggleAudio(for verse: JSONVerse, forcePlay: Bool = false) {
        if isPlayingAudio && !forcePlay {
            stopAudio()
        } else {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set audio session category: \(error)")
            }
            
            let urlString = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/\(verse.id).mp3"
            guard let url = URL(string: urlString) else { return }
            
            let playerItem = AVPlayerItem(url: url)
            audioPlayer = AVPlayer(playerItem: playerItem)
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: playerItem, queue: .main) { _ in
                self.isPlayingAudio = false
            }
            
            audioPlayer?.play()
            isPlayingAudio = true
        }
    }
    
    private func stopAudio() {
        audioPlayer?.pause()
        isPlayingAudio = false
    }
    
    private var bookmarkedIDs: [Int] {
        bookmarkedVerseIDsStr.split(separator: ",").compactMap { Int($0) }
    }
    
    private func toggleBookmark(for id: Int) {
        var current = bookmarkedIDs
        if current.contains(id) {
            current.removeAll { $0 == id }
        } else {
            current.append(id)
        }
        bookmarkedVerseIDsStr = current.map { String($0) }.joined(separator: ",")
    }
    
    private var favoriteSurahs: [Int] {
        favoriteSurahIDsStr.split(separator: ",").compactMap { Int($0) }
    }
    
    private func toggleFavoriteSurah() {
        var current = favoriteSurahs
        if current.contains(surahNumber) {
            current.removeAll { $0 == surahNumber }
        } else {
            current.append(surahNumber)
        }
        favoriteSurahIDsStr = current.map { String($0) }.joined(separator: ",")
    }
}

// MARK: - ReaderSettingsSheet
struct ReaderSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isFullPageMode") private var isFullPageMode = false
    @AppStorage("arabicFont") private var arabicFont = "KFGQPCUthmanTahaNaskh"
    @AppStorage("preferredScript") private var preferredScript = "uthmani"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 38.0
    @AppStorage("translationFontSize") private var translationFontSize: Double = 20.0
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    var previewText: String {
        preferredScript == "indopak" ? "بِسۡمِ اللّٰهِ الرَّحۡمٰنِ الرَّحِيۡمِ" : "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    if isDarkMode {
                        Color(red: 0.10, green: 0.12, blue: 0.11)
                    } else {
                        Color(red: 0.97, green: 0.97, blue: 0.95)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Text("Live Preview")
                                .font(.system(.caption, design: .serif)).bold()
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(previewText)
                                .font(.custom(arabicFont, size: arabicFontSize))
                                .multilineTextAlignment(.center)
                                .baselineOffset(10)
                                .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 24)
                                .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)
                                .clipped()
                                .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                                .id(arabicFont + preferredScript)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            Toggle(isOn: $isDarkMode) {
                                HStack {
                                    Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                        .foregroundColor(isDarkMode ? .yellow : .orange)
                                    Text("Dark Mode")
                                        .font(.system(.body, design: .serif))
                                        .foregroundColor(isDarkMode ? .white : .black)
                                }
                            }
                            .tint(sageGreen)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 4)
                            
                            Divider().background(Color.gray.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reading Mode")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                Picker("Reading Mode", selection: $isFullPageMode) {
                                    Text("Verse by Verse").tag(false)
                                    Text("Full Page").tag(true)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.vertical, 16)
                            
                            Divider().background(Color.gray.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Script Style")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                Picker("Script", selection: $preferredScript) {
                                    Text("Uthmani").tag("uthmani")
                                    Text("IndoPak").tag("indopak")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.vertical, 16)
                            
                            Divider().background(Color.gray.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Arabic Font")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                Picker("Font", selection: $arabicFont) {
                                    Text("Amiri").tag("AmiriQuran-Regular")
                                    Text("Madinah").tag("KFGQPCUthmanTahaNaskh")
                                    Text("Saleem").tag("_PDMS_Saleem_QuranFont")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.vertical, 16)
                            
                            Divider().background(Color.gray.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Arabic Text Size")
                                        .font(.system(.body, design: .serif))
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Text("\(Int(arabicFontSize))")
                                        .font(.system(.subheadline, design: .rounded)).bold()
                                        .foregroundColor(sageGreen)
                                }
                                
                                HStack(spacing: 16) {
                                    Text("A").font(.system(size: 14))
                                    Slider(value: $arabicFontSize, in: 24...64, step: 2)
                                        .tint(sageGreen)
                                    Text("A").font(.system(size: 24))
                                }
                                .foregroundColor(.gray)
                            }
                            .padding(.vertical, 16)
                            
                            Divider().background(Color.gray.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Translation Text Size")
                                        .font(.system(.body, design: .serif))
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Text("\(Int(translationFontSize))")
                                        .font(.system(.subheadline, design: .rounded)).bold()
                                        .foregroundColor(sageGreen)
                                }
                                
                                HStack(spacing: 16) {
                                    Text("A").font(.system(size: 14))
                                    Slider(value: $translationFontSize, in: 14...32, step: 2)
                                        .tint(sageGreen)
                                    Text("A").font(.system(size: 24))
                                }
                                .foregroundColor(.gray)
                                .opacity(isFullPageMode ? 0.5 : 1.0)
                                .disabled(isFullPageMode)
                            }
                            .padding(.vertical, 16)
                        }
                        .padding(.horizontal, 20)
                        .background(isDarkMode ? Color.white.opacity(0.06) : Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Reader Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(sageGreen)
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
