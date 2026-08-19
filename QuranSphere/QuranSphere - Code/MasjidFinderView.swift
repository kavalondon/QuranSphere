import SwiftUI
import MapKit
internal import CoreLocation

struct MasjidFinderView: View {
    @StateObject private var finderManager = MasjidFinderManager()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var userLocation: CLLocation?
    
    // State to control the smooth bottom sheet
    @State private var selectedMosque: MosqueLocation?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.6136, longitude: -2.1585),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    var bgColor: Color {
        isDarkMode ? Color(red: 0.10, green: 0.12, blue: 0.11) : Color(red: 0.97, green: 0.97, blue: 0.95)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            bgColor.ignoresSafeArea()
            
            // MARK: - Top Interactive Map
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: finderManager.mosques) { mosque in
                MapAnnotation(coordinate: mosque.mapItem.placemark.coordinate) {
                    VStack(spacing: 0) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(sageGreen)
                            .clipShape(Circle())
                            .shadow(color: sageGreen.opacity(0.5), radius: 5, x: 0, y: 3)
                        
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(sageGreen)
                            .rotationEffect(.degrees(180))
                            .offset(y: -3)
                    }
                    .onTapGesture {
                        selectedMosque = mosque
                    }
                }
            }
            .frame(height: 320)
            .ignoresSafeArea(edges: .top)
            
            // MARK: - Bottom Sheet List
            VStack(spacing: 0) {
                Spacer().frame(height: 280)
                
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    
                    Text("Nearby Masjids")
                        .font(.system(.title3, design: .serif)).bold()
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.18, green: 0.23, blue: 0.20))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                    
                    if finderManager.isSearching {
                        ProgressView()
                            .padding(.top, 40)
                        Spacer()
                    } else if finderManager.mosques.isEmpty {
                        Text("No mosques found nearby.")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 16) {
                                ForEach(finderManager.mosques) { mosque in
                                    MosqueCardView(mosque: mosque) {
                                        // Open the bottom sheet when tapped
                                        selectedMosque = mosque
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
                .background(bgColor)
                .cornerRadius(32, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
            }
        }
        .onAppear {
            if let location = userLocation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                finderManager.findNearbyMosques(near: location)
            }
        }
        // MARK: - Smooth Premium Bottom Sheet
        .sheet(item: $selectedMosque) { selected in
            NavigationSelectionSheet(mosque: selected)
                // This locks the sheet to only pop up exactly as high as it needs to be
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Navigation Sheet View
struct NavigationSelectionSheet: View {
    let mosque: MosqueLocation
    @Environment(\.dismiss) var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let sageGreen = Color(red: 0.38, green: 0.48, blue: 0.43)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Get Directions")
                .font(.system(.title2, design: .serif).bold())
                .padding(.top, 24)
            
            VStack(spacing: 12) {
                navButton(title: "Apple Maps", icon: "map.fill") {
                    mosque.mapItem.openInMaps(launchOptions: [
                        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                    ])
                    dismiss()
                }
                
                navButton(title: "Google Maps", icon: "g.circle.fill") {
                    let lat = mosque.mapItem.placemark.coordinate.latitude
                    let lng = mosque.mapItem.placemark.coordinate.longitude
                    if let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lng)") {
                        UIApplication.shared.open(url)
                    }
                    dismiss()
                }
                
                navButton(title: "Waze", icon: "car.fill") {
                    let lat = mosque.mapItem.placemark.coordinate.latitude
                    let lng = mosque.mapItem.placemark.coordinate.longitude
                    if let url = URL(string: "https://waze.com/ul?ll=\(lat),\(lng)&navigate=yes") {
                        UIApplication.shared.open(url)
                    }
                    dismiss()
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color.white)
    }
    
    @ViewBuilder
    private func navButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(.headline, design: .rounded))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .foregroundColor(isDarkMode ? .white : .black)
            .padding()
            .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
            .cornerRadius(12)
        }
    }
}


// MARK: - Custom Corner Radius Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
