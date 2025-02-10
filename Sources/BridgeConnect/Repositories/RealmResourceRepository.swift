import Foundation
import RealmSwift
import CoreLocation

final class RealmResourceRepository: ResourceRepository {
    private let realm: Realm
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }
    
    // MARK: - ResourceRepository Protocol
    
    func getAll() async throws -> [Resource] {
        return realm.objects(RealmResource.self)
            .map { $0.toResource() }
    }
    
    func get(id: String) async throws -> Resource? {
        guard let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: id) else {
            return nil
        }
        return realmResource.toResource()
    }
    
    func search(query: String?, location: Location, radius: Double) async throws -> [Resource] {
        let realmResources = realm.objects(RealmResource.self)
            .filter { resource in
                if let query = query?.lowercased(),
                   !resource.name.lowercased().contains(query) &&
                   !resource.resourceDescription.lowercased().contains(query) {
                    return false
                }
                
                let resourceLocation = CLLocation(latitude: resource.latitude, longitude: resource.longitude)
                let searchLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                return resourceLocation.distance(from: searchLocation) <= radius
            }
        
        return realmResources.map { $0.toResource() }
    }
    
    func searchResources(query: String?, location: Location, type: ResourceType?, radius: Double) async throws -> [Resource] {
        let realmResources = realm.objects(RealmResource.self)
            .filter { resource in
                if let query = query?.lowercased(),
                   !resource.name.lowercased().contains(query) &&
                   !resource.resourceDescription.lowercased().contains(query) {
                    return false
                }
                
                if let type = type, resource.type != type.rawValue {
                    return false
                }
                
                let resourceLocation = CLLocation(latitude: resource.latitude, longitude: resource.longitude)
                let searchLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                return resourceLocation.distance(from: searchLocation) <= radius
            }
        
        return realmResources.map { $0.toResource() }
    }
    
    func save(_ resource: Resource) async throws {
        let realmResource = RealmResource(resource: resource)
        try realm.write {
            realm.add(realmResource, update: .modified)
        }
    }
    
    func delete(_ resource: Resource) async throws {
        guard let realmResource = realm.objects(RealmResource.self).first(where: { $0.id == resource.id }) else {
            return
        }
        try realm.write {
            realm.delete(realmResource)
        }
    }
    
    func saveAll(_ resources: [Resource]) async throws {
        let realmResources = resources.map { RealmResource(resource: $0) }
        try realm.write {
            realm.add(realmResources, update: .modified)
        }
    }
    
    func update(_ resource: Resource) async throws {
        let realmResource = RealmResource(resource: resource)
        try realm.write {
            realm.add(realmResource, update: .modified)
        }
    }
    
    func deleteAll(_ resources: [Resource]) async throws {
        let realmResources = resources.compactMap { resource in
            realm.objects(RealmResource.self).first { $0.id == resource.id }
        }
        try realm.write {
            realm.delete(realmResources)
        }
    }
    
    func exists(id: String) async throws -> Bool {
        return realm.object(ofType: RealmResource.self, forPrimaryKey: id) != nil
    }
    
    func count() async throws -> Int {
        return realm.objects(RealmResource.self).count
    }
    
    func getSuggestions(query: String, location: Location, radius: Double) async throws -> [Resource] {
        return try await searchResources(query: query, location: location, type: nil, radius: radius)
    }
} 