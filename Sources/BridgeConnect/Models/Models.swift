import Foundation
import RealmSwift
import CoreLocation

// MARK: - Core Types
public typealias Location = CLLocationCoordinate2D

// MARK: - Resource Model
public enum ResourceType: String, Codable, CaseIterable {
    case foodBank = "food_bank"
    case shelter = "shelter"
    case medical = "medical"
    case mentalHealth = "mental_health"
    case education = "education"
    case employment = "employment"
    case legal = "legal"
    case transportation = "transportation"
    case childcare = "childcare"
    case clothing = "clothing"
    case financial = "financial"
    case other = "other"
    
    public var displayName: String {
        switch self {
        case .foodBank: return "Food Bank"
        case .shelter: return "Shelter"
        case .medical: return "Medical"
        case .mentalHealth: return "Mental Health"
        case .education: return "Education"
        case .employment: return "Employment"
        case .legal: return "Legal"
        case .transportation: return "Transportation"
        case .childcare: return "Childcare"
        case .clothing: return "Clothing"
        case .financial: return "Financial"
        case .other: return "Other"
        }
    }
}

// MARK: - Public Resource Model
public struct Resource: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let resourceDescription: String
    public let type: String
    public let latitude: Double
    public let longitude: Double
    public let contactPhone: String?
    public let contactEmail: String?
    public let contactWebsite: String?
    public let availability: String
    public let lastUpdated: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case resourceDescription = "description"
        case type
        case latitude
        case longitude
        case contactPhone = "phone"
        case contactEmail = "email"
        case contactWebsite = "website"
        case availability
        case lastUpdated
    }
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        type: ResourceType,
        location: CLLocationCoordinate2D,
        phone: String? = nil,
        email: String? = nil,
        website: String? = nil,
        availability: String = "available",
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.resourceDescription = description
        self.type = type.rawValue
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.contactPhone = phone
        self.contactEmail = email
        self.contactWebsite = website
        self.availability = availability
        self.lastUpdated = lastUpdated
    }
    
    init(realmResource: RealmResource) {
        self.id = realmResource.id
        self.name = realmResource.name
        self.resourceDescription = realmResource.resourceDescription
        self.type = realmResource.type
        self.latitude = realmResource.latitude
        self.longitude = realmResource.longitude
        self.contactPhone = realmResource.contactPhone
        self.contactEmail = realmResource.contactEmail
        self.contactWebsite = realmResource.contactWebsite
        self.availability = realmResource.availability
        self.lastUpdated = realmResource.lastUpdated
    }
    
    public static func == (lhs: Resource, rhs: Resource) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Realm Resource Model
final class RealmResource: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var name: String = ""
    @Persisted var resourceDescription: String = ""
    @Persisted var type: String = ""
    @Persisted var latitude: Double = 0
    @Persisted var longitude: Double = 0
    @Persisted var contactPhone: String?
    @Persisted var contactEmail: String?
    @Persisted var contactWebsite: String?
    @Persisted var availability: String = ""
    @Persisted var lastUpdated: Date = Date()
    
    convenience init(resource: Resource) {
        self.init()
        self.id = resource.id
        self.name = resource.name
        self.resourceDescription = resource.resourceDescription
        self.type = resource.type
        self.latitude = resource.latitude
        self.longitude = resource.longitude
        self.contactPhone = resource.contactPhone
        self.contactEmail = resource.contactEmail
        self.contactWebsite = resource.contactWebsite
        self.availability = resource.availability
        self.lastUpdated = resource.lastUpdated
    }
    
    func toResource() -> Resource {
        return Resource(realmResource: self)
    }
}

// MARK: - Search Parameters
public struct SearchParameters: Codable {
    public let query: String?
    public let type: ResourceType?
    public let radius: Double?
    public let limit: Int?
    public let offset: Int?
    
    enum CodingKeys: String, CodingKey {
        case query
        case type
        case radius
        case limit
        case offset
    }
    
    public init(query: String? = nil,
                type: ResourceType? = nil,
                radius: Double? = nil,
                limit: Int? = nil,
                offset: Int? = nil) {
        self.query = query
        self.type = type
        self.radius = radius
        self.limit = limit
        self.offset = offset
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        query = try container.decodeIfPresent(String.self, forKey: .query)
        type = try container.decodeIfPresent(ResourceType.self, forKey: .type)
        radius = try container.decodeIfPresent(Double.self, forKey: .radius)
        limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        offset = try container.decodeIfPresent(Int.self, forKey: .offset)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(query, forKey: .query)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(radius, forKey: .radius)
        try container.encodeIfPresent(limit, forKey: .limit)
        try container.encodeIfPresent(offset, forKey: .offset)
    }
} 