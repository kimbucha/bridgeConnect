import Foundation
import RealmSwift
import CoreLocation

public final class Resource: Object, Identifiable {
    // Basic Information
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var name: String = ""
    @Persisted public var resourceDescription: String = ""
    @Persisted public var type: String = ResourceType.other.rawValue
    
    // Location Information
    @Persisted public var latitude: Double = 0.0
    @Persisted public var longitude: Double = 0.0
    @Persisted public var address: String = ""
    
    // Contact Information
    @Persisted public var phone: String = ""
    @Persisted public var email: String = ""
    @Persisted public var website: String = ""
    @Persisted public var hours: String = ""
    
    // Google Places Information
    @Persisted public var placeId: String = ""
    @Persisted public var rating: Double = 0.0
    @Persisted public var userRatingsTotal: Int = 0
    @Persisted public var photoReference: String?
    @Persisted public var openNow: Bool = false
    @Persisted public var weekdayHours = List<String>()
    @Persisted public var placeTypes = List<String>()
    
    // Distance Information (updated when user location changes)
    @Persisted public var distanceText: String = ""
    @Persisted public var distanceMeters: Int = 0
    @Persisted public var durationText: String = ""
    @Persisted public var durationSeconds: Int = 0
    
    // Timestamps
    @Persisted public var createdAt: Date = Date()
    @Persisted public var updatedAt: Date = Date()
    @Persisted public var lastUpdated: Date = Date()
    
    public convenience init(
        id: String,
        name: String,
        resourceDescription: String,
        type: String,
        address: String,
        coordinate: CLLocationCoordinate2D,
        phone: String,
        website: String,
        hours: [String: String]
    ) {
        self.init()
        self.id = id
        self.name = name
        self.resourceDescription = resourceDescription
        self.type = type
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = address
        self.phone = phone
        self.website = website
        self.hours = hours.map { key, value in "\(key): \(value)" }.joined(separator: "\n")
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastUpdated = Date()
    }
    
    public override var description: String {
        return "Resource(id: \(id), name: \(name), description: \(resourceDescription))"
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    public required override init() {
        super.init()
    }
    
    public convenience init(
        name: String,
        resourceDescription: String,
        type: ResourceType,
        latitude: Double,
        longitude: Double,
        address: String = "",
        phone: String = "",
        email: String = "",
        website: String = ""
    ) {
        self.init()
        self.name = name
        self.resourceDescription = resourceDescription
        self.type = type.rawValue
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.phone = phone
        self.email = email
        self.website = website
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
