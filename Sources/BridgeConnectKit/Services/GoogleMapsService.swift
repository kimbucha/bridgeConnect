import Foundation
import CoreLocation

public enum GoogleMapsError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case noResults
    case rateLimitExceeded
    case encodingError
}

@available(macOS 12.0, *)
public class GoogleMapsService {
    public static var shared: GoogleMapsService!
    
    private let apiKey: String
    private let baseURL = "https://places.googleapis.com/v1/places"
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "X-Goog-Api-Key": apiKey,
            "X-Goog-FieldMask": "places.displayName,places.formattedAddress,places.location,places.types,places.rating,places.userRatingsTotal,places.photos,places.id"
        ]
    }
    
    public func searchNearbyPlaces(
        location: CLLocation,
        resourceTypes: [ResourceType] = ResourceType.allCases,
        maxResults: Int = 20
    ) async throws -> [PlaceSearchResult] {
        let includedTypes = resourceTypes.flatMap { $0.googlePlacesTypes }
        let endpoint = "/search"
        
        let requestBody: [String: Any] = [
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": location.coordinate.latitude,
                        "longitude": location.coordinate.longitude
                    ],
                    "radius": 5000.0
                ]
            ],
            "includedTypes": includedTypes,
            "maxResultCount": maxResults,
            "rankPreference": "DISTANCE"
        ]
        
        let response: PlacesSearchResponse = try await makeRequest(
            endpoint: endpoint,
            body: requestBody
        )
        return response.places
    }
    
    private func makeRequest<T: Decodable>(
        endpoint: String,
        body: [String: Any]
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw GoogleMapsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw GoogleMapsError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GoogleMapsError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        case 429:
            throw GoogleMapsError.rateLimitExceeded
        default:
            throw GoogleMapsError.invalidResponse
        }
    }
}

// Places API Models
public struct PlacesSearchResponse: Codable {
    public let places: [PlaceSearchResult]
    
    private enum CodingKeys: String, CodingKey {
        case places
    }
}


public struct PlaceDisplayName: Codable {
    let text: String
    let languageCode: String
}

public struct PlaceLocation: Codable {
    let latitude: Double
    let longitude: Double
}

public struct PlacePhoto: Codable {
    let name: String
    let widthPx: Int
    let heightPx: Int
}
