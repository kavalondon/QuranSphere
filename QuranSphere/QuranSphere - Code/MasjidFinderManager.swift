import Foundation
import MapKit
internal import Combine
internal import CoreLocation

@MainActor
class MasjidFinderManager: ObservableObject {
    @Published var mosques: [MosqueLocation] = []
    @Published var isSearching = false
    
    private let distanceFormatter: MKDistanceFormatter = {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter
    }()
    
    func findNearbyMosques(near location: CLLocation) {
        isSearching = true
        
        let request = MKLocalSearch.Request()
        // Broad search term to catch all Islamic centers, but we will filter manually below
        request.naturalLanguageQuery = "Mosque"
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response else {
                self?.isSearching = false
                return
            }
            
            var results: [MosqueLocation] = []
            
            // Strict filter to block Apple Maps from showing non-Mosque places of worship
            let excludedWords = ["church", "methodist", "chapel", "cathedral", "synagogue", "temple", "parish", "christ", "st.", "saint"]
            
            for item in response.mapItems {
                let name = item.name ?? "Unknown"
                let nameLowercased = name.lowercased()
                
                // If the name contains any of the excluded words, skip it immediately
                if excludedWords.contains(where: { nameLowercased.contains($0) }) {
                    continue
                }
                
                let mosqueLocation = CLLocation(latitude: item.placemark.coordinate.latitude,
                                                longitude: item.placemark.coordinate.longitude)
                let distanceInMeters = location.distance(from: mosqueLocation)
                let formattedDistance = self.distanceFormatter.string(fromDistance: distanceInMeters)
                
                let mosque = MosqueLocation(
                    id: UUID(),
                    mapItem: item,
                    name: name,
                    distanceString: formattedDistance,
                    distanceInMeters: distanceInMeters
                )
                results.append(mosque)
            }
            
            // Sort by closest distance
            self.mosques = results.sorted(by: { $0.distanceInMeters < $1.distanceInMeters })
            self.isSearching = false
        }
    }
}

// Data model for our UI
struct MosqueLocation: Identifiable {
    let id: UUID
    let mapItem: MKMapItem
    let name: String
    let distanceString: String
    let distanceInMeters: CLLocationDistance
}
