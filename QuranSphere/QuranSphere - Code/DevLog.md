# Development Log: [App Name]

## 📅 July 16, 2026
### Today's Milestones
*   **UI/UX Design:** Implemented a minimalist home dashboard with custom card layouts, featured recitations, and a "Mood Search" bar utilizing emotion emojis.
*   **Database Integration:** Successfully loaded the local `quran_en.json` file.
*   **Branding Update:** Discovered the "QuranSphere" domain is taken; currently brainstorming alternative names, but proceeding with app development under the working title.

### Technical Challenges & Solved Errors
1.  **Swift 6 Compiler Error:** `Ambiguous implicit access level for import of 'Combine'`
    *   *Fix:* Aligned module visibility by using `internal import Combine`.
2.  **Two-Phase Initialization Crash:** `'self' used in method call before all stored properties are initialized`
    *   *Fix:* Restructured the `LocalQuranManager` initializer to define default empty states first before invoking local file parsing methods.
3.  **JSON Key Mismatch Crashes:** `DecodingError.keyNotFound` for `surah_number` and `text`.
    *   *Fix:* Conformed our structures to `Decodable` (removing `Encodable` constraints) and engineered a robust custom decoder with fallback logic to seamlessly map varying JSON keys (`surah`, `surah_number`, `arabic`, `text`) without crashing.

---

## 📅 July 16, 2026
### Today's Milestones
*   **Database Migration:** Upgraded the data layer from a mock 114-verse JSON file to a full local SQLite database containing all 6,236 verses across 114 Surahs.
*   **SQLite Integration:** Integrated Apple's native `SQLite3` framework into `LocalQuranManager` to handle raw SQL compilation, pointer management, and efficient C-string data parsing.
*   **Dynamic Search Engine:** Linked the main UI search and quick-mood selection buttons to execute fast filtered queries against the full offline database layout.

### Technical Challenges & Solved Errors
1.  **Access Control Protection:** Fixed a compiler barrier where `LocalQuranManager` was inaccessible due to an unintended `private` initializer.
2.  **Combine Framework Dependency:** Resolved a missing protocol conformance issue (`ObservableObject`) by explicitly restoring the `Combine` module import required for `@Published` property wrappers.


----
# Developer Log: QuranSphere Database & Navigation Refactor

## 📅 Date: July 16, 2026
## 🛠 Status: COMPLETED (Build Succeeded)

---

## 1. Problem Identification & Root Causes
- **Ambiguous Type & Duplicate Redeclarations:** Xcode compiled duplicate copies of `ContentView.swift` and `SurahListView.swift` because files had been dragged outside of the target folder and reference copies were orphaned at the project root directory.
- **Malformed Translations:** The original translation files contained complex word-by-word metadata notation (e.g., `|164|194||` and `$`) which leaked raw indexes onto the presentation UI.
- **Truncated Surah Catalog:** The catalog was previously restricted to hardcoded arrays, and because the parser was expecting a flat JSON array for 6,236 verses, it repeatedly timed out and fell back to static mock snippets.

---

## 2. Implemented Solutions
- **Directory Consolidation:** Pruned all top-level duplicate files and consolidated active files exclusively inside the nested `/QuranSphere` source folder with checked compiler target memberships.
- **Native SQLite3 Engine Integration:** Swapped the high-overhead `JSONDecoder` out for Swift's native `SQLite3` library, pointing directly to the bundled `quran.db`.
- **Duplicate Prevention Filter:** Bound the SQL query selectively to the `en.sahih` translation identifier in the database schema. This instantly shrunk Al-Fatihah back to its authentic 7 verses, resolved memory bottlenecks, and populated the remaining 114 Surahs.
- **Dynamic Regex Sanitizer:** Integrated an active pattern-matching sanitizer inside `LocalQuranManager.swift` to dynamically strip away metadata symbols on load.
- **UI Restoration:** Restored the premium off-white, sage-green, and sand-palette styling with a floating bottom tab bar.

---

## 3. Data Architecture Summary
- **Database Engine:** `SQLite3` (linking `libsqlite3.tbd`)
- **Query Targets:**
  - `surahs` (Dynamic metadata: Name EN, Name AR, Revelation Type, Verse Count)
  - `ayah_with_translation` (Joined view filtered strictly by `'en.sahih'`)

---

## 📅 July 18, 2026

### Today's Milestones
*   **Unverified SQLite Data Source Deprecation:** The legacy `quran.db` SQLite file lacked institutional verification for its Uthmani script and required complex SQL joins. Completely deprecated the SQLite engine to eliminate the risk of serving inaccurate or malformed text.
*   **Fragmented Authentic Data Integration:** Migrated the data source to the highly verified Quran.com (v4) API. To ensure offline availability and instant loading, three discrete JSON payloads were downloaded and embedded directly into the Xcode bundle: `quran-chapters.json`, `quran-arabic.json` (Tanzil Uthmani), and `quran-english.json` (Sahih International).
*   **Thread Safety Enforcement:** Conformed all application data models (`JSONVerse`, `SurahMetadata`) and the intermediate API decoding structs to the `Sendable` protocol, guaranteeing memory safety when passing the parsed arrays across concurrent boundaries back to the `@MainActor`.

### Technical Challenges & Solved Errors
1.  **UI State Desynchronization in Git Staging:** Xcode's integrated source control sidebar failed to register multi-file selections (Command-click), blocking batch commits.
    *   *Fix:* Bypassed the buggy UI state by utilizing the classic commit sheet (`Option + Command + C`) to explicitly stage and commit feature-specific file groups.
2.  **Hidden Developer Mode & Untrusted Certificates:** Initial deployment to physical hardware was blocked by strict iOS security policies.
    *   *Fix:* Manually forced Developer Mode to appear and trusted the local developer profile via the device's VPN & Device Management settings.
3.  **Infinite USB Pairing Loop:** Xcode failed to mount the developer disk image and remained stuck in a "Pairing is in process" loop due to a frozen `usbmuxd` daemon.
    *   *Fix:* Broke the loop by executing `sudo killall usbmuxd` in the macOS Terminal to force a clean USB handshake.
4.  **Missing Provisioning Profile:** Deployment threw a "Signing requires a development team" error.
    *   *Fix:* Resolved the build failure by assigning a Personal Team Apple ID and enabling automatic signing management for the app target.
5.  **Main Actor Isolation Violations:** Swift 6's new strict concurrency checking aggressively flagged `LocalQuranManager`, throwing `Main actor-isolated` errors because the heavy JSON decoding was occurring inside an `ObservableObject` (which inherently binds to the UI thread).
    *   *Fix:* Abstracted the parsing logic out of the manager and into a dedicated `QuranDataParser` struct. Applied the `nonisolated` keyword and `Task.detached` to explicitly force the decoding engine off the Main Actor, preventing UI lockups during app launch.
6.  **Deprecated View Modifiers:** Compiler warnings in `QiblaCompassView.swift` for legacy iOS 16 `.onChange` modifiers.
    *   *Fix:* Resolved compiler warnings by updating legacy iOS 16 `.onChange` modifiers to comply with the modern zero/two-parameter closure syntax mandated by iOS 17+.

---
📅 July 19, 2026
Today's Milestones
•    Gamified Reader Interface Integration: Completely overhauled the QuranReaderView from a continuous scrolling list into a Quranly-inspired, single-verse flashcard layout. Integrated interactive progression controls and automated state preservation via @AppStorage to track the user's exact reading position and global completion progress.
•    Dynamic JSON UI Wiring: Successfully bridged the SurahListView directly to the LocalQuranManager. The application now dynamically parses and renders the full 114-Surah directory from the embedded quran-chapters.json payload, featuring real-time indexing and a custom horizontal carousel for frequently accessed Surahs.
•    Architectural Component Modularization: Refactored the monolithic ContentView into granular, reusable subcomponents. Abstracted repetitive layout code into custom view modifiers (.minimalCardStyle) to significantly clean up the main view hierarchy and reduce code duplication.
Technical Challenges & Solved Errors
    1.    POSIX Code 22 Compiler Failure: The build system failed to compile the project and threw a silent Invalid argument error because the source code directory was imported as a raw Folder Reference (blue folder) rather than an Xcode Group.
•    Fix: Re-mapped the project hierarchy by converting the raw directory selection into a standard Xcode Group (yellow folder), successfully exposing the embedded Swift files to the compiler.
    2.    Main Thread Text Input Stutter: Typing in the homescreen's search bar caused severe UI lag. Because the TextField was bound to a @State variable on the root ContentView, SwiftUI was aggressively redrawing the entire homescreen (including heavy grid components) on every keystroke.
•    Fix: Encapsulated the text input into an isolated MinimalSearchBar view. This localized the @State mutations to the child view during typing, explicitly deferring the parent view update until the onSubmit closure fired.
    3.    NavigationLink Touch Interception: Routing cards placed within a LazyVGrid or ScrollView frequently ignored user inputs, requiring multiple rapid taps to register a navigation event due to SwiftUI's default list-style touch handling.
•    Fix: Enforced .buttonStyle(PlainButtonStyle()) across all interactive routing components to strip the default highlighting behaviors and restore instantaneous single-tap responsiveness.
    4.    EnvironmentObject Type Mismatch: The compiler threw cryptic requires wrapper 'EnvironmentObject.Wrapper' and no dynamic member errors. The new UI was querying for a chapters array and a transliteration property, but the data manager was exposing a surahs array containing nameEN.
•    Fix: Renamed the @Published data array to chapters and injected computed properties (var transliteration: String { nameEN }) directly into the SurahMetadata model, seamlessly bridging the parsed JSON keys to the UI's expected variables without disrupting the backend decoder.

---

📅 July 19, 2026
Today's Milestones
•    Audio & Interactivity Activation: Successfully hooked up AVFoundation to stream Mishary Alafasy recitations directly from the Islamic Network API for individual verses. Replaced static placeholder buttons with a fully functional iOS ShareLink for exporting verses and built out robust bookmarking logic tied directly to @AppStorage.
•    Unified Dark Mode Engine: Resolved severe legibility issues (black text on dark backgrounds/white text on light backgrounds) across both the SurahListView and QuranReaderView. Implemented structural .preferredColorScheme() modifiers to bridge the custom @AppStorage dark mode toggle with system-level UI elements, ensuring navigation bars and dynamic text colors flip correctly.
Technical Challenges & Solved Errors
1.    Invisible Tap Targets in Lists: Surah cards within the SurahListView were completely unclickable. The NavigationLink was wrapped around an EmptyView() inside a ZStack, which SwiftUI renders with a zero-pixel size, resulting in no physical tap area.
•    Fix: Replaced EmptyView() with an expanding Color.clear layer over the visual components, making the entire card a clean, clickable surface while preserving the custom chevron-free design.
2.    Mutating State on Immutable Values: The Swift compiler threw a "Cannot use mutating member on immutable value: 'self' is immutable" error when attempting to toggle favorite Surah IDs. The function was trying to mutate a computed property from inside a standard, non-mutating SwiftUI struct.
•    Fix: Bypassed the computed property setter and updated the underlying @AppStorage string directly (favoriteSurahIDsStr = current.map...), allowing SwiftUI's built-in property wrappers to handle the state change safely without requiring mutating methods.
3.    Missing Type in Scope Compilation Errors: The build system failed with a cascade of cryptic errors (Generic parameter 'C' could not be inferred, Cannot infer key path type from context, and Cannot find type 'SurahMetadataModel' in scope) when the view attempted to iterate over the Surah list.
•    Fix: Identified that the static 114-Surah metadata payload had been accidentally truncated from the bottom of the file during a previous copy-paste. Restored the full SurahMetadataModel struct, instantly resolving the compiler's generic inference and scoping failures.

----

📅 July 20, 2026
Today's Milestones
•    Qibla Compass Engine & Reverse Geocoding: Engineered a custom Qibla compass utilizing CoreLocation and spherical trigonometry to calculate exact bearings to the Kaaba completely offline. Integrated a lightweight CLGeocoder to efficiently translate raw GPS coordinates into localized city and country displays while preserving device battery life.
•    Bookmarks Hub Integration: Developed a dedicated BookmarksView that seamlessly decodes comma-separated verse IDs from @AppStorage. Built an elegant preview card UI that parses the embedded JSON database to render saved verses and instantly route users back to their exact reading position in the QuranReaderView.
•    Hardware Audio Bypass: Confirmed the Islamic Network CDN streaming infrastructure is 100% free and fair-use, and successfully restructured the AVPlayer implementation to bypass iOS hardware constraints for seamless, high-quality audio streaming.
Technical Challenges & Solved Errors
    1.    Blank ScrollView Collapse: The QiblaCompassView rendered as a completely blank screen because it utilized flexible Spacer() elements within the parent ContentView's infinite vertical ScrollView, which squished the layout to exactly zero pixels.
•    Fix: Applied a strict .frame(minHeight: 600) modifier to the compass container, forcing it to occupy its required vertical space and preventing the parent scroll view from crushing the UI elements.
    2.    Dual-Needle Alignment Confusion: The initial compass design utilized separate needles for North and Qibla, creating a mathematically confusing UX where users attempted to align two disparate rotational values.
•    Fix: Overhauled the layout to feature a fixed "Forward" chevron at the top of the screen. Bound the mathematical Qibla bearing directly to a geometric Kaaba icon, allowing users to intuitively rotate their physical device until the Kaaba aligned perfectly with the top marker, confirmed via a custom haptic lock.
    3.    Hardware Silent Switch Muting: AVPlayer executed successfully with no errors, but physical devices output zero sound. iOS was aggressively muting the audio stream because the physical hardware ringer switch was toggled to silent.
•    Fix: Implemented an explicit AVAudioSession override, setting the audio category to .playback and activating the session prior to stream initialization. This signaled to the OS that the stream was essential user-requested media, forcing playback out loud regardless of the physical ringer state.


---

# 🚀 Devlog: July 22, 2026 - Thematic Search & Settings Architecture

## 🌟 Overview
Today's focus was on heavily refining the user experience on the Home Screen. We overhauled the mood search engine to be much more empathetic and context-aware, introduced the foundation for the Gamification Dashboard, and completely decoupled the Home Screen typography settings from the main Quran Reader settings.

## 🛠 Features & Updates

### 1. Empathetic "Mood Search" Engine (`QuranSearchManager`)
*   **Thematic Interception Map:** Upgraded the search engine to intercept emotional keywords (e.g., "lonely", "angry", "anxious") and route users to curated, comforting verses rather than relying on raw text matching.
*   **Pooled Randomization:** Expanded the thematic arrays significantly. The engine now pools all relevant verses for a mood and selects one randomly, ensuring the user doesn't see the same verse repeatedly.
*   **Curated Safety Blocklist:** Implemented a robust `isSafe` filter to silently block explicit or inappropriate search queries. Carefully curated the list to ensure legitimate Quranic topics (e.g., "death", "angel of death") are still searchable.

### 2. Dashboard Gamification UI
*   **Continue Reading:** Added a dynamic "Continue Reading" section on the Home Screen that pulls from `@AppStorage` to display the last read Surah and Verse.
*   **Stats Overview:** Built the UI shell for the Gamification stats, including Current Streak, Daily Verses goal, and the Hasanat counter.

### 3. Decoupled Typography Settings (`MoodCardSettingsView`)
*   **Independent AppStorage:** Created distinct `@AppStorage` variables (`moodArabicFont`, `moodArabicFontSize`, `moodScriptStyle`) so users can adjust their Home Screen cards without altering their main reading experience.
*   **Live Preview Interface:** Built a dedicated `MoodCardSettingsView` featuring a live, reactive preview card that updates instantly as users adjust sliders and pickers.
*   **Settings Integration:** Integrated the new settings page into the main `SettingsView` using a native iOS card design. Resolved a notorious SwiftUI `NavigationLink` nesting bug to ensure buttery-smooth routing.

## 🧠 Technical Learnings
*   **SwiftUI Routing:** Discovered that nesting a `NavigationLink` inside a `ScrollView` that is already inside a parent `ScrollView` causes Apple's gesture recognizer to swallow the tap. Flattening the view hierarchy resolves the `EXC_BAD_ACCESS` crashes and tap issues perfectly.


----

# 🚀 Devlog: July 22, 2026 - Gamification Engine & Robust Search Safety

## 🌟 Overview
Today's focus was on bringing the app to life by implementing the core mathematics for the gamification system, building a native Islamic calendar integration, and heavily fortifying the thematic search engine against abuse. We also squashed several SwiftUI routing bugs to ensure buttery-smooth navigation.

## 🛠 Features & Updates

### 1. The Hasanat & Gamification Engine (`GamificationManager`)
*   **Hasanat Math Engine:** Built a lightweight logic manager that intercepts raw Arabic text, strips non-letter characters (spaces), and awards 10 *hasanat* (good deeds) per letter read, strictly following the Sunnah.
*   **Ramadan Multiplier:** Integrated Apple's native `.islamicUmmAlQura` calendar. The engine automatically detects the 9th Islamic month (Ramadan) and dynamically applies a 70x multiplier (700 hasanat per letter).
*   **Daily Streaks:** Built an automatic date-checking system using `UserDefaults` that compares the current date to the `lastReadDate`, gracefully incrementing the streak or resetting daily goals to 0 at midnight.
*   **Reader Integration:** Wired the manager into `QuranReaderView`, utilizing SwiftUI's `.onAppear` and `.id()` modifiers to invisibly track reading progress as the user pages through verses.

### 2. Search Safety & Hard-Blocking (`QuranSearchManager`)
*   **Comprehensive Blocklist:** Massively expanded the explicit filter to include modern internet slang, profanity, and explicit terminology, while preserving clinical/theological terms necessary for legitimate Quranic study.
*   **Punctuation Stripping:** Closed a loophole where users could bypass the filter using punctuation (e.g., "word!"). 
*   **Hard-Block UI:** Replaced the silent redirect with a "Hard Block" mechanism. If a banned word is detected, the search engine instantly aborts, clears the query, and wipes the ghost results from the screen to provide clear, rigid feedback.

### 3. Navigation & Filtering Fixes
*   **Favourite Surahs Routing:** Updated `ContentView` Quick Links to pass a boolean flag to `SurahListView`. The list now automatically snaps to the "Favourites" filter pill and dynamically updates the Navigation Title when accessed via the Quick Link.
*   **Settings Routing:** Resolved a notoriously tricky SwiftUI bug where nested `ScrollViews` swallowed `NavigationLink` taps, ensuring the new Mood Settings card taps instantly.

## 🧠 Technical Learnings
*   **Swift Native Capabilities:** Leveraging Swift's built-in `CharacterSet.punctuationCharacters` and the native Islamic Calendar (`.islamicUmmAlQura`) removes the need for clunky regex or third-party APIs, keeping the app incredibly fast and lightweight.

---

# Devlog: UI Polish & Native Launch Screen
**Date:** July 26, 2026

## 🎯 Summary
Focused on improving the user experience of the Tahajjud Guide by streamlining the content, integrating custom photography, and building a lightning-fast, native launch screen from scratch.

## 🎨 UI & UX Improvements
* **Tahajjud Guide Refactor:** Simplified the text content for better scannability while preserving essential Hadith and Quranic references.
* **Custom Asset Integration:** Replaced generic SF Symbols with custom, step-by-step photography (`salah-step-01` through `salah-step-09`) to visually guide users through the prayer.
* **Image Sizing Fixes:** Updated the SwiftUI card layout to dynamically scale images within a constrained container, utilizing `.clipShape` to keep the rounded corners clean.

## ⚙️ Technical Highlights
* **Native Launch Screen Implementation:** Bypassed artificial loading screens and older storyboard methods. Implemented a purely native launch screen using the `UILaunchScreen` dictionary in Xcode's Info tab for instantaneous loading.
* **Dynamic Theming:** Configured the launch screen background to adapt automatically to user settings (Sage Green for Light Mode, Dark Slate for Dark Mode).
* **Asset Resolution Scaling:** Utilized Xcode's 2x/3x scaling slots to ensure the central launch logo renders at the perfect size and maximum sharpness across all iPhone screens.
* **Overcoming Simulator Caching:** Successfully troubleshooted and bypassed iOS's aggressive launch screen caching through strategic asset renaming and raw key configuration.


-----

# Devlog: UI Polish, Native Launch Screen & New Guides Section
**Date:** July 26, 2026

## 🎯 Summary
Focused on improving the user experience by building a lightning-fast native launch screen and expanding the app's educational content. Introduced a brand-new Guides & Learning hub designed to be accessible and straightforward for beginners.

## 📚 Guides & Learning Hub
* **New Section Created:** Added a dedicated learning section offering guides on "How to Pray", "Tahajjud", "Dhikr", and "How to Make Dua".
* **New Card Layout:** Implemented a clean, elegant card-based menu system to help users navigate educational topics effortlessly.
* **The Complete Prayer Guide:** Built a comprehensive breakdown for Salah, specifically keeping information simple and to the point for beginners or those needing a refresher. 
* **Guide Categories:** The prayer guide includes structured sub-sections: Introduction to Salah, Prayer Times & Rak'ahs, Purification (Wudu'), How to Perform Salah, and Short Qur'anic Chapters.

## 🎨 UI & UX Improvements
* **Tahajjud Guide Refactor:** Simplified the text content for better scannability while preserving essential Hadith and Quranic references.
* **Custom Asset Integration:** Replaced generic SF Symbols with custom, step-by-step photography to visually guide users through the prayer.
* **Image Sizing Fixes:** Updated the SwiftUI card layout to dynamically scale images within a constrained container, utilizing `.clipShape` to keep the rounded corners clean.

## ⚙️ Technical Highlights
* **Native Launch Screen Implementation:** Bypassed artificial loading screens. Implemented a purely native launch screen using the `UILaunchScreen` dictionary in Xcode's Info tab for instantaneous loading.
* **Dynamic Theming:** Configured the launch screen background to adapt automatically to user settings (Sage Green for Light Mode, Dark Slate for Dark Mode).
* **Asset Resolution Scaling:** Utilized Xcode's 2x/3x scaling slots to ensure the central launch logo renders at the perfect size and maximum sharpness across all iPhone screens.
* **Overcoming Simulator Caching:** Successfully troubleshooted and bypassed iOS's aggressive launch screen caching through strategic asset renaming and raw key configuration.


## ⚙️ Technical Highlights
•    Tactile Qibla Alignment & Haptics: Implemented precise directional haptic feedback using iOS system vibration APIs (UIImpactFeedbackGenerator), giving users a tactile pulse effect the exact moment their phone aligns with the Kaaba heading.
•    Prayer Time Calculation Accuracy: Refined prayer calculation engine settings (adjusting calculation methods, twilight angles, and high-latitude adjustments) to guarantee precise Adhan and Prayer times based on the user's exact geographical location.
•    Rich Quran Data Model & Multi-Script Integration: Upgraded the core JSONVerse and QuranDataParser logic to locally parse and support rich Uthmani, IndoPak (ara-quranindopak.json), and English Transliteration (ara-quran-la.json) datasets without relying on web APIs.
•    Arabic Diacritic & Waqf Mark Rendering: Eliminated text clipping of complex Arabic ligatures, stopping marks (Meems, Jeems), and Tajweed symbols in QuranReaderView by replacing rigid .lineSpacing constraints with safe .baselineOffset and vertical padding modifiers.
•    High-Performance Search Optimization: Refactored local verse searching to evaluate pre-computed lowercase translation strings (searchableTranslation) during initial background parsing, completely eliminating main-thread keypress lag for instant lookups.
•    Search Bar Focus Responsiveness: Fixed a UI usability bug in SurahListView by binding an explicit @FocusState to the search TextField and adding container .onTapGesture triggers, ensuring the keyboard and cursor activate on the very first tap.
•    Surah Nomenclature Normalization: Programmatically normalized Surah 36 metadata across static datasets and computed properties to ensure it displays cleanly and consistently as "Yaseen" across all headers and lists.


##  Devlog: Unicode Arabic Text Sanitization, UI Refinement & Accessibility Polish
Date: August 12, 2026
🎯 Summary
Focused on perfecting the core reading experience by resolving missing-glyph rendering bugs at the Unicode level for IndoPak scripts, decluttering the verse navigation interface, and hardening the app with robust accessibility and background audio capabilities for App Store readiness.
🛠️ Detailed List of Changes & Updates
1. Arabic Text Rendering & Unicode Sanitization
•    Unicode-Level Text Cleaning: Upgraded the arabicText(for:) function inside LocalQuranManager.swift to enforce strict Unicode scalar filtering when IndoPak script is active, ensuring output is restricted exclusively to valid Arabic script blocks and whitespace.
•    Missing Glyph ([?]) Elimination: Resolved persistent rendering bugs where custom TrueType fonts (such as PDMS Saleem) lacked character glyph mappings for specialized dataset pause marks, completely eradicating fallback placeholder boxes across all script and font combinations.
•    Layout & Diacritic Protection: Prevented text clipping of complex Arabic ligatures and Tajweed symbols in QuranReaderView by substituting rigid .lineSpacing constraints with safe .baselineOffset and vertical padding modifiers.
2. UI Polish & Navigation Refinements
•    Clutter-Free Verse Navigation: Removed clunky floating sliders and replaced them with an intuitive, minimalist Tap-to-Jump Menu integrated into the header, preserving a distraction-free reading atmosphere.
•    Independent Translation Sizing: Introduced an @AppStorage-backed translation font size slider inside ReaderSettingsSheet, allowing users to adjust English text scaling independently from Arabic script.
•    Surah Nomenclature Normalization: Programmatically standardized Surah metadata rules to ensure Surah 36 displays consistently as "Yaseen" across all view hierarchies.
•    Instant Play/Stop Toggle: Added .animation(nil, value: isPlayingAudio) to the audio recitation buttons to instantly swap states without crossfades or opacity transitions.
3. Performance & Architecture
•    High-Performance Search Optimization: Refactored local verse searching to evaluate pre-computed lowercase translation strings (searchableTranslation) during initial background parsing, removing main-thread keypress lag.
•    Search Bar Responsiveness: Bound an explicit @FocusState to search input fields and added container gesture triggers to guarantee immediate keyboard and cursor activation on first touch.
•    Rich Multi-Script Integration: Upgraded core JSON data parsers to cleanly manage localized Uthmani, IndoPak, and English Transliteration datasets locally.
4. App Store Readiness & Accessibility
•    Tactile Haptic Feedback: Embedded light system haptic generators (UIImpactFeedbackGenerator) across bookmarks, favorite toggles, audio playback, and navigation controls.
•    Audio Auto-Advance & Background Play: Configured AVPlayerItemDidPlayToEndTime notifications to seamlessly auto-advance to the next verse and trigger audio playback continuously, supported by explicit background audio capabilities in Xcode.
•    VoiceOver Accessibility Compliance: Added explicit .accessibilityLabel tags to all core icon buttons to guarantee full screen-reader support.


**

## Devlog: Widgets, Deep Linking, and UI Overhaul
Date: August 13, 2026

Module: QuransphereWidget & QiblaCompassView

🚀 Features & Updates
1. Home Screen Widget implementation
• Built a Standalone Extension: Created a medium-sized widget that operates completely independently of App Groups for initial testing and design iteration.
• Pillars-Inspired Layout: Designed a sleek, hierarchical grid layout. The top half prominently displays the next prayer and its time, while the bottom half features a 5-prayer horizontal timeline with active-state indicators (gold dot and bold text).
• iOS 17 Compatibility: Adopted the new .containerBackground(for: .widget) API required by Apple to prevent background rendering crashes on modern devices.
• Branding: Applied the core QuranSphere palette (pillarsSage, pillarsWarmSand, pillarsBackgroundDark, and pillarsAccentGold) with full Light/Dark mode support reflecting system settings.
2. Deep Linking Architecture
• Widget Routing: Added the .widgetURL() modifier to broadcast a custom URL scheme (quransphere://qibla) when the user taps the widget.
• App-Side Handling: Implemented the .onOpenURL modifier in the root ContentView. When the widget is tapped, the app wakes up, intercepts the URL, and seamlessly animates the custom floating tab bar over to the Qibla/Prayers page.
3. Qibla & Prayer Times UI Redesign
• Separation of Concerns (UX): Separated the Qibla Compass and the Prayer Times list to prevent visual clutter and give the premium compass UI room to breathe.
• Custom Sliding Toggle: Built a bespoke, pill-shaped segmented control at the top of the screen. Utilized SwiftUI's @Namespace and .matchedGeometryEffect for a fluid, physics-based sliding animation when switching tabs.
• SwiftUI Layout Bug Fix: Encountered a native SwiftUI bug where placing a swipeable TabView inside a parent ScrollView caused the views to collapse to 0 pixels in height.
• The Solution: Bypassed TabView entirely by using dynamic conditional rendering (if selectedTab == ...) paired with .transition(.opacity.combined(with: .scale(scale: 0.98))). This guaranteed the pages render at full height while maintaining a buttery-smooth page swap animation.
• Preserved Authentic Logic: Successfully re-injected the original CoreLocation math, Aladhan API fetcher, and UIImpactFeedbackGenerator (Taptic Engine) without altering the authentic code.
🔜 Next Steps
• Adhaan Notifications: Implement UNUserNotificationCenter to schedule local notifications when prayer times arrive.
• Audio Trimming: Crop the Adhaan .wav file to meet Apple's strict 30-second limit for custom notification alerts.
• App Group Integration: Set up the paid Apple Developer account to enable App Groups, allowing the main app's live Aladhan data to feed directly into the widget target.



***

🚀 Devlog: Session Update Summary
•    Qibla Compass & Navigation Improvements
•    Dynamic Direction Text: Implemented real-time dynamic instruction text ("Turn to your left", "Turn to your right", "You're facing Makkah") that updates smoothly based on the user's continuous compass heading.
•    Interactive Sliding Toggle: Enhanced the sliding tab toggle with .contentShape(Rectangle()) and smooth spring animations to make switching between the Qibla Compass and Prayer Times instantaneous and responsive on the first tap.
•    Widget Deep-Linking: Added a .widgetURL(URL(string: "quransphere://qibla")) to the Prayer Times widget and configured .onOpenURL inside ContentView to ensure tapping the home screen widget routes the user directly to the Qibla tab.
•    Guides & Learning Section
•    Istikhara Guide: Added a brand-new, comprehensive Istikhara guide card to the homepage (GuidesSectionView) routing to a dedicated detail view (IstikharaGuideView).
•    Structured Content & Minimalist UI: Styled the Istikhara guide using the app's core design system (custom card modifiers, breathing room, clear step-by-step UI markers, and dedicated split cards for Arabic text, transliteration, and English translation).
•    Prayer Notifications & Background Management
•    Local Notification System: Built PrayerNotificationManager utilizing UserNotifications to automatically schedule and handle local alerts for all 5 daily prayers.
•    Automatic Sync: Integrated notification scheduling directly into PrayerTimesView so that alerts update dynamically whenever prayer times are calculated or refreshed.
•    Quran Reader UI & Text Cleanup
•    Minimalist Card Redesign: Updated QuranReaderView to unify the Arabic text and English translation into a single, cohesive container card with clean shadows, matching the app's minimalist home dashboard aesthetic.
•    Advanced Footnote Sanitizer: Upgraded the translation cleaner function with robust Unicode regular expressions ([\p{L}\.,]\d+) to completely strip out annoying inline footnote numbers attached to words and punctuation.


# Feature: 5 Pillars of Islam Guide 🕌

## Overview
This update introduces the **5 Pillars of Islam** learning page to the `GuidesSectionView`. The UI has been carefully crafted to strictly adhere to the app's premium, minimalist aesthetic, using a custom soft-beige background, serif typography, and flat, crisp cards.

## 🗂 Files Changed

*   **`GuidesSectionView.swift`** (Modified)
    *   Appended `GuideCard` for "5 Pillars" to the `howToGuides` array.
    *   Updated the `LazyVGrid` routing logic to correctly navigate to `FivePillarsView()` when the card is tapped.
*   **`FivePillarsView.swift`** (New)
    *   Created a brand new SwiftUI view from scratch to display the 5 pillars (Shahada, Salah, Zakat, Sawm, Hajj).
    *   Implemented the custom `PillarModel` struct for clean data mapping.

## ✨ UI / UX Details
To maintain consistency with the existing guide templates (e.g., the *Tahajjud Guide*), the following specific design choices were implemented:

*   **Custom Navigation:** Hidden default Apple `NavigationBar` in favor of a custom floating white circular button with a black chevron for dismissal.
*   **Color Palette:**
    *   Background: Soft off-white/beige `Color(red: 0.97, green: 0.96, blue: 0.94)`.
    *   Accents: Muted Gold `Color(red: 0.83, green: 0.66, blue: 0.53)` for the header icon and Primary Green `Color(red: 0.38, green: 0.48, blue: 0.43)` for the number badges.
*   **Typography:** Heavily utilized `.serif` design on fonts (`.title3`, `.body`, `.subheadline`) to maintain the traditional, elegant feel.
*   **Card Styling:** Stripped away heavy drop-shadows. Used pure white backgrounds with a delicate 1px border (`Color.black.opacity(0.06)`) for a crisp, paper-like UI.

## 🛠 How to Test
1. Pull the latest branch to your local machine.
2. Open `QuranSphere.xcodeproj` / `QuranSphere.xcworkspace`.
3. Press **Cmd + Shift + K** to clean the build folder.
4. Press **Cmd + R** to run the app in the simulator.
5. Navigate to the **Guides & Learning** section.
6. Tap the new **5 Pillars** card and verify the routing, custom back button functionality, and UI alignment.

## 📝 Notes for Future Development
*   If adding more guides in the future, reference the layout structure in `FivePillarsView.swift` to ensure the custom navigation bar and background color logic remain consistent across all detail pages.

# DevLog: QuranSphere iOS Utility App

## Date: August 15, 2026
### Milestone: Core Privacy-First Utility & Gamified Engagement Engine

---

### 🚀 Overview & Accomplishments
Today marked a major leap forward in the architecture and user engagement loop of **QuranSphere**. We successfully integrated our long-term reading goal trackers, refined the home screen layout for maximum clarity, and established robust local notification workflows—all while staying strictly faithful to our core privacy commitment (zero user accounts, zero server-side databases, and full local persistence via `AppStorage` and `UserDefaults`).

---

### 🛠️ Key Technical Implementations

1. **Unified Spiritual Progress Dashboard (`ContentView`)**
   - Consolidated the home screen layout by merging the daily streaks, verse reading goals, hasanat tracker, and the newly introduced Khatmah tracking metrics into a single, cohesive card.
   - Eliminated visual clutter and card fatigue on the main view while preserving instant visibility into daily milestones.

2. **Khatmah Completion Manager & Interactive Sheet (`KhatmahManager.swift`)**
   - Created a reactive `ObservableObject` manager backed by Combine and `@AppStorage` to track global reading progress against customized timeframe goals (e.g., 30, 60, or 90-day completion cycles).
   - Designed a dedicated interactive configuration sheet (`KhatmahSettingsSheet`) allowing users to easily adjust, set, or reset their personal Khatmah pace on demand.

3. **Uplifting Daily Push Notifications & Deep Link Routing**
   - Expanded `NotificationManager` to schedule recurring local morning notifications featuring uplifting verses of the day.
   - Built custom payload handling via `userInfo` dictionaries and `.onOpenURL` deep-linking logic, routing users directly from their morning push notification straight to the target Surah and verse reader.

4. **Codebase Cleanup & Architecture Hardening**
   - Resolved protocol conformance requirements and strict Swift import rules (`internal import Combine`).
   - Cleaned up redundant UI subcomponents to ensure a smooth, native, high-performance user experience.

---

### 📱 Next Steps / Roadmap
* **Background Audio & Lock Screen Controls:** Implement `AVAudioSession` categories to allow recitation audio to continue seamlessly when locking the device or switching apps.
* **Custom Bookmark Tagging:** Build localized categorical sorting for saved verses to turn bookmarks into an organized personal spiritual journal.
