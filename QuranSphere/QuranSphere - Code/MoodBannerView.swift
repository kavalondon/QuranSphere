import SwiftUI

struct MoodBannerView: View {
    let query: String
    @EnvironmentObject var quranManager: LocalQuranManager
    
    @State private var detectedMood: String? = nil
    
    var body: some View {
        Group {
            if let mood = detectedMood {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Verses of Comfort")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text("For when you feel \(mood.capitalized)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .task(id: query) {
            // 1. If the query is empty, clear the mood and exit immediately
            guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                detectedMood = nil
                return
            }
            
            // 2. THE DEBOUNCE: Wait 0.3 seconds (300,000,000 nanoseconds)
            // If the user types another letter before 0.3s is up, SwiftUI cancels this task,
            // throwing an error here and preventing the heavy search from running!
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
            } catch {
                return // User kept typing, abort this search!
            }
            
            // 3. The user has paused typing for 0.3s. Now we run the heavy search safely.
            detectedMood = quranManager.detectedMood(for: query)
        }
    }
}
