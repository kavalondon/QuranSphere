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
    
    // 🌟 NEW: Pre-lowercased translation to make searching lightning fast!
    let searchableTranslation: String
    
    let transliteration: String
    let words: [VerseWord]?
    
    var text: String { textUthmani }
    
    func arabicText(for script: String) -> String {
        return script.lowercased() == "indopak" ? textIndopak : textUthmani
    }
}

struct SurahMetadata: Identifiable, Sendable {
    let id: Int
    let nameEN: String
    let nameAR: String
    let nameTranslation: String
    let totalVerses: Int
    let type: String
    
    var transliteration: String { nameEN }
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
        // Enforce the 3 base files
        guard let chaptersUrl = Bundle.main.url(forResource: "quran-chapters", withExtension: "json"),
              let arabicUrl = Bundle.main.url(forResource: "quran-arabic", withExtension: "json"),
              let englishUrl = Bundle.main.url(forResource: "quran-english", withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        
        let decoder = JSONDecoder()
        let chaptersResponse = try decoder.decode(QChaptersResponse.self, from: Data(contentsOf: chaptersUrl))
        let arabicResponse = try decoder.decode(QVersesResponse.self, from: Data(contentsOf: arabicUrl))
        let englishResponse = try decoder.decode(QTranslationsResponse.self, from: Data(contentsOf: englishUrl))
        
        // Crash-proof loading for the rich text files
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
            // 🌟 THE FIX: Rename Surah 36 from Ya-Sin to Yaseen
            var englishName = chapter.nameSimple
            if chapter.id == 36 {
                englishName = "Yaseen"
            }
            
            let metadata = SurahMetadata(
                id: chapter.id,
                nameEN: englishName,
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
                searchableTranslation: cleanTranslation.lowercased(), // 🌟 THE FIX: Pre-compute the lowercase string once!
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
        // 1. Sadness, Grief, & Depression
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

        // 2. Anxiety, Stress, & Feeling Overwhelmed
        "anxious": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "29:69", "64:11", "9:51", "33:3", "39:36"],
        "anxiety": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "29:69", "64:11", "9:51", "33:3", "39:36"],
        "nervous": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "9:51", "39:36"],
        "stressed": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "29:69", "64:11", "9:51", "2:286", "65:2"],
        "stress": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "29:69", "64:11", "9:51", "2:286", "65:2"],
        "overwhelmed": ["2:286", "20:46", "3:173", "65:3", "13:28", "94:5", "94:6", "2:153"],
        "panic": ["20:46", "3:173", "8:40", "9:40", "13:28"],
        "😰": ["13:28", "20:46", "3:139", "65:3", "8:40", "2:153", "3:173", "29:69"],
        "😖": ["2:286", "65:3", "13:28", "94:5", "94:6"],
        "😓": ["13:28", "20:46", "3:139", "65:3", "2:286"],
        "😵‍💫": ["13:28", "20:46", "3:173", "65:3", "2:286"],

        // 3. Hopelessness, Despair, & Feeling Lost
        "hopeless": ["39:53", "12:87", "94:5", "94:6", "2:214", "65:7", "42:28", "15:56", "2:216"],
        "despair": ["39:53", "12:87", "15:56", "94:5", "94:6", "42:28"],
        "defeated": ["3:139", "2:214", "94:5", "94:6", "21:87", "12:87", "65:7"],
        "lost": ["93:7", "2:156", "2:286", "20:46", "18:24", "2:186"],
        "broken": ["2:152", "2:153", "2:286", "21:89", "11:115", "13:28"],
        "giving up": ["39:53", "12:87", "94:5", "94:6", "2:214", "3:139", "15:56"],
        "🥀": ["39:53", "12:87", "94:5", "94:6", "2:214", "65:7", "42:28"],
        "😞": ["39:53", "94:5", "94:6", "2:286", "12:86", "3:139"],

        // 4. Loneliness & Isolation
        "lonely": ["50:16", "2:186", "20:46", "9:40", "57:4", "58:7", "6:59", "2:152"],
        "alone": ["50:16", "2:186", "20:46", "9:40", "57:4", "58:7", "6:59", "11:61"],
        "isolated": ["50:16", "2:186", "20:46", "9:40", "57:4", "58:7", "6:59"],
        "abandoned": ["93:3", "50:16", "2:186", "20:46", "9:40", "57:4", "58:7"],
        "misunderstood": ["50:16", "6:59", "20:46", "2:186"],
        "🚶": ["50:16", "2:186", "20:46", "9:40", "57:4", "58:7"],
        "🥺": ["50:16", "2:186", "20:46", "9:40", "57:4", "93:3"],

        // 5. Anger & Frustration
        "angry": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43", "2:153", "23:96"],
        "anger": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43", "2:153", "23:96"],
        "frustrated": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43", "3:186"],
        "annoyed": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43"],
        "mad": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43", "2:153"],
        "furious": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43"],
        "😡": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43"],
        "🤬": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43"],
        "😤": ["3:134", "7:199", "41:34", "25:63", "42:37", "42:43", "2:153"],

        // 6. Gratitude, Happiness & Contentment
        "grateful": ["14:7", "55:13", "2:152", "31:12", "27:19", "2:172", "16:114"],
        "thankful": ["14:7", "55:13", "2:152", "31:12", "27:19", "2:172", "16:114"],
        "happy": ["14:7", "55:13", "2:152", "31:12", "27:19", "2:172", "10:58", "93:11"],
        "joyful": ["10:58", "14:7", "55:13", "2:152", "31:12", "27:19", "2:172"],
        "blessed": ["93:11", "14:7", "55:13", "2:152", "31:12", "27:19", "2:172"],
        "content": ["13:28", "89:27", "89:28", "14:7", "2:152"],
        "😊": ["14:7", "55:13", "2:152", "31:12", "27:19", "2:172", "10:58", "93:11"],
        "❤️": ["14:7", "55:13", "2:152", "31:12", "27:19", "2:172", "10:58"],
        "🥰": ["14:7", "55:13", "2:152", "31:12", "27:19", "2:172", "10:58"],
        "✨": ["14:7", "55:13", "2:152", "31:12", "27:19", "93:11"],
        "🙏": ["14:7", "55:13", "2:152", "31:12", "27:19", "2:172", "40:60"],

        // 7. Exhaustion, Burnout, & Weakness
        "tired": ["28:24", "2:286", "94:5", "94:6", "73:6", "78:9", "40:60", "3:139", "11:115"],
        "exhausted": ["28:24", "2:286", "94:5", "94:6", "73:6", "78:9", "40:60", "3:139", "11:115"],
        "weak": ["28:24", "2:286", "40:60", "3:139", "11:115", "8:46"],
        "weary": ["28:24", "2:286", "94:5", "94:6", "73:6", "78:9", "40:60", "3:139", "11:115"],
        "burnt out": ["28:24", "2:286", "94:5", "94:6", "78:9", "3:139", "11:115"],
        "🥱": ["28:24", "2:286", "78:9", "94:5", "94:6"],
        "😴": ["78:9", "28:24", "2:286", "73:6"],
        "😪": ["28:24", "2:286", "94:5", "94:6", "78:9", "11:115"],

        // 8. Guilt, Regret & Seeking Forgiveness
        "guilty": ["39:53", "3:135", "4:110", "2:222", "7:23", "20:82", "42:25", "66:8", "71:10", "8:33", "11:90"],
        "sinful": ["39:53", "3:135", "4:110", "2:222", "7:23", "20:82", "42:25", "66:8", "71:10", "8:33", "11:90"],
        "regret": ["39:53", "3:135", "4:110", "2:222", "7:23", "20:82", "42:25", "66:8", "71:10", "8:33", "11:90"],
        "regretful": ["39:53", "3:135", "4:110", "2:222", "7:23", "20:82", "42:25", "66:8", "71:10", "8:33", "11:90"],
        "sorry": ["39:53", "3:135", "4:110", "2:222", "7:23", "20:82", "42:25", "66:8", "71:10", "8:33", "11:90"],
        "forgiveness": ["39:53", "3:135", "4:110", "2:222", "7:23", "20:82", "42:25", "66:8", "71:10", "8:33", "11:90"],
        "ashamed": ["39:53", "3:135", "4:110", "2:222", "7:23", "20:82", "42:25", "66:8", "71:10", "8:33", "11:90"],
        "🤲": ["39:53", "3:135", "4:110", "2:222", "7:23", "20:82", "42:25", "66:8", "71:10", "8:33", "11:90", "40:60"],

        // 9. Fear & Being Scared
        "scared": ["20:46", "9:40", "3:175", "2:38", "2:112", "3:173", "8:40", "10:62"],
        "fear": ["20:46", "9:40", "3:175", "2:38", "2:112", "3:173", "8:40", "10:62"],
        "fearful": ["20:46", "9:40", "3:175", "2:38", "2:112", "3:173", "8:40", "10:62"],
        "terrified": ["20:46", "9:40", "3:175", "2:38", "2:112", "3:173", "8:40", "10:62"],
        "afraid": ["20:46", "9:40", "3:175", "2:38", "2:112", "3:173", "8:40", "10:62"],
        "😨": ["20:46", "9:40", "3:175", "2:38", "2:112", "3:173", "8:40", "10:62"],
        "😱": ["20:46", "9:40", "3:175", "2:38", "2:112", "3:173", "8:40", "10:62"],
        "👻": ["20:46", "9:40", "3:175", "2:38", "2:112", "3:173", "8:40", "10:62"],

        // 10. Doubt & Confusion
        "doubtful": ["2:2", "2:186", "24:35", "2:256", "2:260", "3:8", "21:25"],
        "confused": ["2:2", "2:186", "24:35", "2:256", "2:260", "3:8", "21:25", "20:114"],
        "unsure": ["2:2", "2:186", "24:35", "2:256", "2:260", "3:8", "21:25", "20:114"],
        "lost faith": ["2:2", "2:186", "24:35", "2:256", "2:260", "3:8", "21:25"],
        "doubt": ["2:2", "2:186", "24:35", "2:256", "2:260", "3:8", "21:25"],
        "🤔": ["2:2", "2:186", "24:35", "2:256", "2:260", "3:8", "21:25", "20:114"],
        "❓": ["2:2", "2:186", "24:35", "2:256", "2:260", "3:8", "21:25", "20:114"],

        // 11. Impatience & Waiting
        "impatient": ["2:153", "3:200", "11:115", "12:83", "70:5", "31:17", "103:3", "16:127"],
        "waiting": ["2:153", "3:200", "11:115", "12:83", "70:5", "31:17", "103:3", "16:127"],
        "rushed": ["2:153", "3:200", "11:115", "12:83", "70:5", "31:17", "103:3", "16:127"],
        "impatience": ["2:153", "3:200", "11:115", "12:83", "70:5", "31:17", "103:3", "16:127"],
        "⏳": ["2:153", "3:200", "11:115", "12:83", "70:5", "31:17", "103:3", "16:127"],
        "⏰": ["2:153", "3:200", "11:115", "12:83", "70:5", "31:17", "103:3", "16:127"],
        "⌛": ["2:153", "3:200", "11:115", "12:83", "70:5", "31:17", "103:3", "16:127"],

        // 12. Sickness & Physical Pain
        "sick": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14"],
        "ill": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14"],
        "pain": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14"],
        "unwell": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14"],
        "hurting": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14", "2:153", "2:286"],
        "disease": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14"],
        "🤒": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14"],
        "🤕": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14"],
        "🏥": ["26:80", "21:83", "10:57", "17:82", "41:44", "9:14"],

        // 13. Seeking Peace, Calm & Serenity
        "peace": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        "calm": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        "serenity": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        "contentment": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        "peaceful": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        "🧘": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        "🕊️": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        "🌅": ["13:28", "89:27", "89:28", "89:29", "89:30", "2:112", "10:25", "48:4", "36:58"],
        
        // 14. Laziness & Procrastination
        "lazy": ["94:7", "3:133", "23:60", "2:148", "53:39", "9:54", "4:142"],
        "laziness": ["94:7", "3:133", "23:60", "2:148", "53:39", "9:54", "4:142"],
        "procrastinating": ["94:7", "3:133", "23:60", "2:148", "53:39", "18:23", "18:24"],
        "unmotivated": ["94:7", "3:133", "23:60", "2:148", "53:39", "9:54"],
        
        // 15. Jealousy & Envy
        "jealous": ["113:5", "4:32", "2:109", "4:54", "16:71"],
        "jealousy": ["113:5", "4:32", "2:109", "4:54", "16:71"],
        "envy": ["113:5", "4:32", "2:109", "4:54", "16:71"],
        "envious": ["113:5", "4:32", "2:109", "4:54", "16:71"],
        
        // 16. Injustice & Being Wronged
        "injustice": ["3:140", "4:135", "42:39", "42:41", "60:8", "4:58"],
        "oppressed": ["3:140", "4:135", "42:39", "42:41", "60:8", "4:58", "2:286"],
        "wronged": ["3:140", "4:135", "42:39", "42:41", "60:8", "4:58"],
        "unfair": ["3:140", "4:135", "42:39", "42:41", "60:8", "4:58"]
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
        
        // 🌟 THE FIX: Lightning fast search using the pre-computed lowercase string!
        // Because Arabic letters don't have uppercase/lowercase, we can just use standard .contains()
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
