import SwiftUI

struct MoodBannerView: View {
    let query: String
    @EnvironmentObject var quranManager: LocalQuranManager
    
    // 🌟 THE FIX: Move the function call outside of the `body`
    // This stops Xcode from confusing it with a SwiftUI Binding
    private var detectedMood: String? {
        quranManager.detectedMood(for: query)
    }
    
    var body: some View {
        // Now the body just safely checks a simple variable
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
}
