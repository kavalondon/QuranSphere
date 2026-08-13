import Foundation
import SwiftUI
internal import Combine

// MARK: - YOUR APP'S DATA MODELS

struct VerseWord: Codable, Sendable {
    let arabic: String
    let transliteration: String
    let translation: String
}

struct JSONVerse: Identifiable, Sendable {
    let id: Int
    let surahNumber: Int
    let verseNumber: Int
    
    let textUthmani: String
    let textIndopak: String
    let translation: String
    let searchableTranslation: String
    let transliteration: String
    let words: [VerseWord]?
    
    var text: String { textUthmani }
    
    // 🌟 UNICODE-LEVEL SANITIZER: Strips out any character lacking a font glyph to prevent [?] boxes
    func arabicText(for script: String) -> String {
        let rawText = script.lowercased() == "indopak" ? textIndopak : textUthmani
        
        if script.lowercased() == "indopak" {
            // Keep only valid Arabic letters, standard spaces, and Arabic diacritics (Harakat / Unicode blocks 0600-06FF)
            let filteredScalars = rawText.unicodeScalars.filter { scalar in
                // Allow standard whitespace
                if scalar.properties.isWhitespace { return true }
                // Allow standard Arabic block (0600–06FF) and Arabic Supplement (0750–077F)
                let value = scalar.value
                let isArabicBlock = (value >= 0x0600 && value <= 0x06FF) || (value >= 0x0750 && value <= 0x077F) || (value >= 0xFB50 && value <= 0xFDFF)
                return isArabicBlock
            }
            return String(filteredScalars).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return rawText
    }
}

struct SurahMetadata: Identifiable, Sendable {
    let id: Int
    let nameEN: String
    let nameAR: String
    let nameTranslation: String
    let totalVerses: Int
    let type: String
    
    var transliteration: String {
        return id == 36 ? "Yaseen" : nameEN
    }
    
    var name: String { nameAR }
    var translation: String { nameTranslation }
}

// MARK: - BACKGROUND PARSER & DECODING MODELS
private struct QuranDataParser: Sendable {
    
    private struct QChaptersResponse: Codable, Sendable { let chapters: [QChapter] }
    private struct QChapter: Codable, Sendable {
        let id: Int
        let nameSimple: String
        let nameArabic: String
        let translatedName: QTranslatedName
        let versesCount: Int
        let revelationPlace: String
        
        enum CodingKeys: String, CodingKey {
            case id, nameSimple = "name_simple", nameArabic = "name_arabic", translatedName = "translated_name", versesCount = "verses_count", revelationPlace = "revelation_place"
        }
    }
    private struct QTranslatedName: Codable, Sendable { let name: String }

    private struct QVersesResponse: Codable, Sendable { let verses: [QVerse] }
    private struct QVerse: Codable, Sendable {
        let id: Int
        let verseKey: String
        let textUthmani: String?
        let textIndopak: String?
        
        enum CodingKeys: String, CodingKey {
            case id, verseKey = "verse_key", textUthmani = "text_uthmani", textIndopak = "text_indopak"
        }
    }

    private struct QTranslationsResponse: Codable, Sendable { let translations: [QTranslation] }
    private struct QTranslation: Codable, Sendable { let text: String }

    private struct FawazQuranResponse: Codable, Sendable { let quran: [FawazVerse] }
    private struct FawazVerse: Codable, Sendable { let text: String }

    static func parseData() throws -> ([SurahMetadata], [JSONVerse]) {
        guard let chaptersUrl = Bundle.main.url(forResource: "quran-chapters", withExtension: "json"),
              let arabicUrl = Bundle.main.url(forResource: "quran-arabic", withExtension: "json"),
              let englishUrl = Bundle.main.url(forResource: "quran-english", withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        
        let decoder = JSONDecoder()
        let chaptersResponse = try decoder.decode(QChaptersResponse.self, from: Data(contentsOf: chaptersUrl))
        let arabicResponse = try decoder.decode(QVersesResponse.self, from: Data(contentsOf: arabicUrl))
        let englishResponse = try decoder.decode(QTranslationsResponse.self, from: Data(contentsOf: englishUrl))
        
        var translitResponse: FawazQuranResponse? = nil
        if let url = Bundle.main.url(forResource: "quran-transliteration", withExtension: "json"), let data = try? Data(contentsOf: url) {
            translitResponse = try? decoder.decode(FawazQuranResponse.self, from: data)
        }
        
        var uthmaniResponse: FawazQuranResponse? = nil
        if let url = Bundle.main.url(forResource: "quran-uthmani", withExtension: "json"), let data = try? Data(contentsOf: url) {
            uthmaniResponse = try? decoder.decode(FawazQuranResponse.self, from: data)
        }
        
        var indopakResponse: FawazQuranResponse? = nil
        if let url = Bundle.main.url(forResource: "quran-indopak", withExtension: "json"), let data = try? Data(contentsOf: url) {
            indopakResponse = try? decoder.decode(FawazQuranResponse.self, from: data)
        }
        
        var loadedSurahs: [SurahMetadata] = []
        var loadedVerses: [JSONVerse] = []
        
        for chapter in chaptersResponse.chapters {
            let metadata = SurahMetadata(
                id: chapter.id,
                nameEN: chapter.nameSimple,
                nameAR: chapter.nameArabic,
                nameTranslation: chapter.translatedName.name,
                totalVerses: chapter.versesCount,
                type: chapter.revelationPlace.capitalized
            )
            loadedSurahs.append(metadata)
        }
        
        for (index, arVerse) in arabicResponse.verses.enumerated() {
            let enVerse = englishResponse.translations[index]
            
            let richUthmaniText = uthmaniResponse?.quran.indices.contains(index) == true ? uthmaniResponse!.quran[index].text : (arVerse.textUthmani ?? "Text unavailable")
            let richIndopakText = indopakResponse?.quran.indices.contains(index) == true ? indopakResponse!.quran[index].text : (arVerse.textIndopak ?? richUthmaniText)
            let transVerseText = translitResponse?.quran.indices.contains(index) == true ? translitResponse!.quran[index].text : ""
            
            let components = arVerse.verseKey.split(separator: ":")
            let surahNum = Int(components[0]) ?? 0
            let verseNum = Int(components[1]) ?? 0
            
            let cleanTranslation = enVerse.text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            
            let verse = JSONVerse(
                id: arVerse.id,
                surahNumber: surahNum,
                verseNumber: verseNum,
                textUthmani: richUthmaniText,
                textIndopak: richIndopakText,
                translation: cleanTranslation,
                searchableTranslation: cleanTranslation.lowercased(),
                transliteration: transVerseText,
                words: nil
            )
            loadedVerses.append(verse)
        }
        
        return (loadedSurahs, loadedVerses)
    }
}

// MARK: - EXHAUSTIVE MOOD & EMOTION MAPPER
struct MoodMapper {
    static let dictionary: [String: [String]] = [
        "sad": ["94:5", "94:6", "2:286", "9:40", "12:86", "3:139", "21:87", "39:53", "20:46", "10:107", "40:60", "2:153", "13:28", "3:200", "8:46"],
        "sadness": ["94:5", "94:6", "2:286", "9:40", "12:86", "3:139", "21:87", "39:53", "20:46", "10:107", "40:60", "2:153", "13:28"],
        "depressed": ["94:5", "94:6", "2:286", "9:40", "12:86", "3:139", "21:87", "39:53", "13:28", "40:60"],
        "depression": ["94:5", "94:6", "2:286", "9:40", "12:86", "3:139", "21:87", "39:53", "13:28", "40:60"],
        "grief": ["12:86", "2:155", "2:156", "2:157", "9:40", "21:87", "39:53", "94:5", "94:6"],
        "grieving": ["12:86", "2:155", "2:156", "2:157", "9:40", "21:87", "39:53", "94:5", "94:6"],
        "sorrow": ["12:86", "9:40", "3:139", "94:5", "94:6", "21:87"],
        "😔": ["94:5", "94:6", "2:286", "9:40", "12:86", "3:139", "21:87", "39:53", "20:46", "10:107", "40:60"],
        "😢": ["12:86", "94:5", "94:6", "2:153", "21:87", "39:53"],
        "😭": ["12:86", "2:286", "94:5", "94:6", "40:60", "21:87"],
        "💔": ["2:152", "2:153", "2:286", "21:89", "11:115", "13:28"],
        "anxious": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "29:69", "64:11", "9:51", "33:3", "39:36"],
        "anxiety": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "29:69", "64:11", "9:51", "33:3", "39:36"],
        "stressed": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "29:69", "64:11", "9:51", "2:286", "65:2"],
        "peace": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        "calm": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"]
    ]
}

class LocalQuranManager: ObservableObject {
    @Published var verses: [JSONVerse] = []
    @Published var chapters: [SurahMetadata] = []
    
    init() {
        Task {
            await loadQuranData()
        }
    }
    
    private func loadQuranData() async {
        do {
            let (newChapters, newVerses) = try await Task.detached {
                try await QuranDataParser.parseData()
            }.value
            
            await MainActor.run {
                self.chapters = newChapters
                self.verses = newVerses
            }
        } catch {
            print("❌ JSON Parsing Error: \(error)")
        }
    }
    
    func findVerses(for query: String) -> [JSONVerse] {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if cleanQuery.isEmpty { return [] }
        
        if let mappedVerseKeys = MoodMapper.dictionary[cleanQuery] {
            return getShuffledMoodVerses(keys: mappedVerseKeys)
        }
        
        let words = cleanQuery.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            if let mappedVerseKeys = MoodMapper.dictionary[cleanWord] {
                return getShuffledMoodVerses(keys: mappedVerseKeys)
            }
        }
        
        return verses.filter {
            $0.searchableTranslation.contains(cleanQuery) ||
            $0.textUthmani.contains(cleanQuery) ||
            $0.textIndopak.contains(cleanQuery)
        }
    }
    
    private func getShuffledMoodVerses(keys: [String]) -> [JSONVerse] {
        let moodVerses = verses.filter { verse in
            let key = "\(verse.surahNumber):\(verse.verseNumber)"
            return keys.contains(key)
        }
        return moodVerses.shuffled()
    }
    
    func detectedMood(for query: String) -> String? {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if MoodMapper.dictionary.keys.contains(cleanQuery) {
            return cleanQuery
        }
        
        let words = cleanQuery.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            if MoodMapper.dictionary.keys.contains(cleanWord) {
                return cleanWord
            }
        }
        
        return nil
    }
}
