import Foundation
import CoreLocation

public struct PlaceSearchResult: Codable {
    public let id: String
    public let displayName: DisplayName
    public let formattedAddress: String
    public let location: Location
    public let types: [String]
    public let rating: Double?
    public let userRatingCount: Int?
    public let photos: [Photo]?
    
    public var primaryType: String {
        return types.first ?? "point_of_interest"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case formattedAddress
        case location
        case types
        case rating
        case userRatingCount = "userRatingsTotal"
        case photos
    }
    
    public init(id: String, displayName: DisplayName, formattedAddress: String, location: Location, types: [String], rating: Double?, userRatingCount: Int?, photos: [Photo]?) {
        self.id = id
        self.displayName = displayName
        self.formattedAddress = formattedAddress
        self.location = location
        self.types = types
        self.rating = rating
        self.userRatingCount = userRatingCount
        self.photos = photos
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decode(DisplayName.self, forKey: .displayName)
        formattedAddress = try container.decode(String.self, forKey: .formattedAddress)
        location = try container.decode(Location.self, forKey: .location)
        types = try container.decode([String].self, forKey: .types)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        userRatingCount = try container.decodeIfPresent(Int.self, forKey: .userRatingCount)
        photos = try container.decodeIfPresent([Photo].self, forKey: .photos)
    }
}

public struct DisplayName: Codable {
    public let text: String
    public let languageCode: String
}

public struct Location: Codable {
    public let latitude: Double
    public let longitude: Double
}

public struct Photo: Codable {
    public let name: String
    public let widthPx: Int
    public let heightPx: Int
}
