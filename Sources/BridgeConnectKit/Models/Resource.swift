import Foundation
import RealmSwift

public final class Resource: Object, Identifiable {
    @Persisted(primaryKey: true) public var id: String = UUID().uuidString
    @Persisted public var name: String = ""
    @Persisted public var resourceDescription: String = ""
    
    public override var description: String {
        return "Resource(id: \(id), name: \(name), description: \(resourceDescription))"    
    }
    @Persisted public var type: String = ""
    @Persisted public var latitude: Double = 0.0
    @Persisted public var longitude: Double = 0.0
    @Persisted public var address: String = ""
    @Persisted public var phone: String = ""
    @Persisted public var email: String = ""
    @Persisted public var website: String = ""
    @Persisted public var createdAt: Date = Date()
    @Persisted public var updatedAt: Date = Date()
    
    public required override init() {
        super.init()
    }
    
    public convenience init(
        name: String,
        resourceDescription: String,
        type: String,
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
        self.type = type
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
