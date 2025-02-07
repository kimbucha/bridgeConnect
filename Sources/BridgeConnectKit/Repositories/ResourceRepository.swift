import Foundation
import RealmSwift

public final class ResourceRepository {
    public static let shared = ResourceRepository()
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    // MARK: - Create
    
    public func save(_ resource: Resource) throws {
        try realm.write {
            resource.updatedAt = Date()
            realm.add(resource, update: .modified)
        }
    }
    
    // MARK: - Read
    
    public func getAllResources() -> Results<Resource> {
        return realm.objects(Resource.self).sorted(byKeyPath: "name")
    }
    
    public func getResource(id: String) -> Resource? {
        return realm.object(ofType: Resource.self, forPrimaryKey: id)
    }
    
    public func searchResources(query: String) -> Results<Resource> {
        return realm.objects(Resource.self)
            .filter("name CONTAINS[c] %@ OR description CONTAINS[c] %@", query, query)
            .sorted(byKeyPath: "name")
    }
    
    public func getNearbyResources(latitude: Double, longitude: Double, radiusInMeters: Double) -> Results<Resource> {
        // Calculate bounding box for rough filtering
        let latDelta = radiusInMeters / 111000 // rough conversion to degrees
        let lonDelta = radiusInMeters / (111000 * cos(latitude * .pi / 180))
        
        let minLat = latitude - latDelta
        let maxLat = latitude + latDelta
        let minLon = longitude - lonDelta
        let maxLon = longitude + lonDelta
        
        return realm.objects(Resource.self)
            .filter("latitude >= %f AND latitude <= %f AND longitude >= %f AND longitude <= %f",
                   minLat, maxLat, minLon, maxLon)
            .sorted(byKeyPath: "name")
    }
    
    // MARK: - Update
    
    public func update(_ resource: Resource, with updates: (Resource) -> Void) throws {
        try realm.write {
            updates(resource)
            resource.updatedAt = Date()
        }
    }
    
    // MARK: - Delete
    
    public func delete(_ resource: Resource) throws {
        try realm.write {
            realm.delete(resource)
        }
    }
    
    public func deleteAll() throws {
        try realm.write {
            realm.deleteAll()
        }
    }
} 