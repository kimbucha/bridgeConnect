import Foundation
import RealmSwift

@available(macOS 10.15, *)
public final class ResourceRepository {
    public static let shared = ResourceRepository()
    public let realm: Realm
    
    public init() {
        do {
            realm = try Realm()
            if realm.objects(Resource.self).isEmpty {
                loadInitialData()
            }
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    private func loadInitialData() {
        guard let url = Bundle(for: type(of: self)).url(forResource: "default", withExtension: "csv") else {
            print("Failed to locate resource \"default.csv\"")
            return
        }
        
        do {
            let content = try String(contentsOf: url)
            let rows = content.components(separatedBy: "\n").dropFirst() // Skip header
            
            let resources = rows.compactMap { row -> Resource? in
                let columns = row.components(separatedBy: ",")
                guard columns.count >= 5,
                      let latitude = Double(columns[3]),
                      let longitude = Double(columns[4]) else {
                    return nil
                }
                
                let resource = Resource()
                resource.name = columns[0].trimmingCharacters(in: CharacterSet.whitespaces)
                resource.type = columns[1].trimmingCharacters(in: CharacterSet.whitespaces)
                resource.resourceDescription = columns[2].trimmingCharacters(in: CharacterSet.whitespaces)
                                                      .replacingOccurrences(of: "\"", with: "")
                resource.latitude = latitude
                resource.longitude = longitude
                resource.updatedAt = Date()
                return resource
            }
            
            try realm.write {
                realm.add(resources)
            }
        } catch {
            print("Failed to load initial data: \(error)")
        }
    }
    
    // MARK: - Create
    
    public func save(_ resource: Resource) throws {
        try realm.write {
            resource.updatedAt = Date()
            realm.add(resource, update: .modified)
        }
    }
    
    public func batchSave(resources: [Resource]) throws {
        try realm.write {
            for resource in resources {
                resource.updatedAt = Date()
                realm.add(resource, update: .modified)
            }
        }
    }
    
    public func saveResources(_ resources: [Resource]) async throws {
        try await MainActor.run {
            try realm.write {
                let now = Date()
                resources.forEach { resource in
                    resource.updatedAt = now
                    realm.add(resource, update: .modified)
                }
            }
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