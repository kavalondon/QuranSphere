import SwiftUI
import AVFoundation

struct QuranReaderView: View {
    let surahNumber: Int
    let surahName: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var quranManager: LocalQuranManager
    
    // Core Progress Trackers
    @AppStorage("isDarkMode") private var isDarkMode = false
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
    @State private var currentVerseIndex: Int = 0
    @State private var showSettings = false
    
    // Audio Player State
    @State private var audioPlayer: AVPlayer?
    @State private var isPlayingAudio = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    private func cleanTranslationText(_ rawText: String) -> String {
        var text = rawText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // 1. Remove any digit attached immediately after a period, comma, or letter (e.g., ".2", ".3", "wombs.3", "Merciful.2")
        text = text.replacingOccurrences(of: "([\\p{L}\\.,])\\d+", with: "$1", options: .regularExpression)
        
        // 2. Remove any remaining isolated digits or bracketed footnote numbers like [1] or (2)
        text = text.replacingOccurrences(of: "\\[\\d+\\]|\\(\\d+\\)|\\b\\d+\\b", with: "", options: .regularExpression)
        
        // 3. Clean up any leftover double spaces or awkward punctuation gaps
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        ZStack {
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
                    headerSection
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Spacer().frame(height: 12)
                            
                            // UNIFIED READING CARD (Arabic + Translation inside one clean container)
                            VStack(spacing: 24) {
                                verseHeader
                                
                                Text(surahVerses[currentVerseIndex].arabicText(for: preferredScript))
                                    .font(.custom(arabicFont, size: arabicFontSize))
                                    .multilineTextAlignment(.center)
                                    .baselineOffset(10)
                                    .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                                    .frame(maxWidth: .infinity, minHeight: 120)
                                    .padding(.vertical, 8)
                                    .id(arabicFont + preferredScript + "\(surahVerses[currentVerseIndex].id)")
                                    .onAppear {
                                        GamificationManager.shared.logVerseRead(arabicText: surahVerses[currentVerseIndex].arabicText(for: preferredScript))
                                    }
                                
                                Divider()
                                    .opacity(0.4)
                                    .padding(.horizontal, 12)
                                
                                Text(cleanTranslationText(surahVerses[currentVerseIndex].translation))
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
                    
                    bottomControls
                }
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadVerses() }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
            if currentVerseIndex < surahVerses.count - 1 {
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
        .sheet(isPresented: $showSettings) {
            ReaderSettingsSheet()
        }
    }
    
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
                
                Spacer(minLength: 4)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(sageGreen)
                    Text("Daily Reading")
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
        }
    }
    
    private var bottomControls: some View {
        HStack {
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
            
            Button(action: {
                triggerHaptic()
                stopAudio()
                dismiss()
            }) {
                Text("I'm Done")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(isDarkMode ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isDarkMode ? Color.white : Color(red: 0.18, green: 0.23, blue: 0.20))
                    .cornerRadius(25)
            }
            
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
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    private func loadVerses() {
        let filtered = quranManager.verses.filter { $0.surahNumber == surahNumber }
        surahVerses = filtered.sorted { $0.verseNumber < $1.verseNumber }
        
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
        
        let totalVersesInQuran = 6236.0
        readingProgress = min(readingProgress + (1.0 / totalVersesInQuran), 1.0)
    }
    
    private func restartSurah() {
        if currentVerseIndex > 0 {
            stopAudio()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentVerseIndex = 0
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

// ReaderSettingsSheet remains unchanged below...
struct ReaderSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
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
