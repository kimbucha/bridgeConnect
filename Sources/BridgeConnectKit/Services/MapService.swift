import Foundation
import MapKit
import CoreLocation

/// A service that handles map-related functionality using Apple's MapKit
public class MapService: NSObject {
    public static var shared: MapService!
    private let searchRadius: CLLocationDistance = 5000 // 5km radius
    
    public override init() {
        super.init()
    }
    
    /// Search for places near a given location
    /// - Parameters:
    ///   - location: The location to search around
    ///   - types: The categories of places to search for
    /// - Returns: An array of place search results
    public func searchNearbyPlaces(
        location: CLLocation,
        types: [ResourceCategory]
    ) async throws -> [PlaceSearchResult] {
        let searchTerms = types.flatMap { $0.types }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerms.joined(separator: " OR ")
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: searchRadius,
            longitudinalMeters: searchRadius
        )
        
        let search = MKLocalSearch(request: request)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PlaceSearchResult], Error>) in
            search.start { response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response else {
                    continuation.resume(throwing: BridgeConnectKitError.locationError("No search results found"))
                    return
                }
                let results = response.mapItems.map { item in
                    let displayName = DisplayName(text: item.name ?? "", languageCode: "en")
                    let location = Location(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                    return PlaceSearchResult(
                        id: item.name ?? UUID().uuidString,
                        displayName: displayName,
                        formattedAddress: item.placemark.title ?? "",
                        location: location,
                        types: ["point_of_interest"],
                        rating: nil as Double?,
                        userRatingCount: nil as Int?,
                        photos: nil as [Photo]?
                    )
                }
                continuation.resume(returning: results)
            }
        }
    }

    /// Get directions between two locations
    /// - Parameters:
    ///   - source: Starting location
    ///   - destination: Ending location
    /// - Returns: A route between the locations
    public func getDirections(
        source: CLLocationCoordinate2D,
        destination: CLLocationCoordinate2D
    ) async throws -> MKRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MKRoute, Error>) in
            directions.calculate { response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response, let route = response.routes.first else {
                    continuation.resume(throwing: BridgeConnectKitError.locationError("No route found"))
                    return
                }
                continuation.resume(returning: route)
            }
        }
    }
}


