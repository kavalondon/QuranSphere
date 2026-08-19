import SwiftUI
import MapKit

struct MosqueCardView: View {
    let mosque: MosqueLocation
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // We pass the tap action up so the parent view can show the bottom sheet smoothly
    let onNavigateTap: () -> Void
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    let accentGold = Color(red: 0.83, green: 0.67, blue: 0.51)
    
    var body: some View {
        Button(action: onNavigateTap) {
            HStack(spacing: 16) {
                
                // MARK: - Refined Circular Icon
                ZStack {
                    Circle()
                        .fill(sageGreen.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(sageGreen)
                }
                
                // MARK: - Mosque Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(mosque.name)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        .lineLimit(1)
                    
                    Text(mosque.mapItem.placemark.title ?? "Address unavailable")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // MARK: - Right Action Area (Distance & Button)
                VStack(alignment: .trailing, spacing: 8) {
                    Text(mosque.distanceString)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentGold)
                    
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(sageGreen)
                }
            }
            .padding(16)
            .background(isDarkMode ? Color(red: 0.15, green: 0.17, blue: 0.16) : Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(isDarkMode ? 0.3 : 0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents the whole card from highlighting weirdly on tap
    }
}
