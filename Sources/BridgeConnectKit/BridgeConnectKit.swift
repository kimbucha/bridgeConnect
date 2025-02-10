import Foundation
import RealmSwift
import CoreLocation

/// BridgeConnectKit is the main framework for handling emergency resource management.
/// It provides services for location, mapping, and resource persistence.
///
/// Usage:
/// ```swift
/// do {
///     try BridgeConnectKit.shared.initialize()
/// } catch {
///     print("Failed to initialize: \(error)")
/// }
/// ```

/// Errors that can occur within BridgeConnectKit
public enum BridgeConnectKitError: Error {
    /// Thrown when the framework fails to initialize properly
    case initializationError(String)
    /// Thrown when required configuration is missing or invalid
    case configurationError(String)
    /// Thrown when location services are unavailable or unauthorized
    case locationError(String)
}

@available(macOS 12.0, *)
public final class BridgeConnectKit {
    public static let shared = BridgeConnectKit()
    
    public private(set) var mapService: MapService!
    public private(set) var locationService: LocationService!
    public private(set) var resourceRepository: ResourceRepository!
    
    private init() {}
    
    public func initialize() throws {
        // Initialize services
        mapService = MapService()
        MapService.shared = mapService
        
        // Initialize Realm
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: Resource.className()) { oldObject, newObject in
                        // Set default value for new hours field
                        newObject!["hours"] = ""
                    }
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
        
        // Initialize services
        locationService = LocationService()
        resourceRepository = ResourceRepository()
        
        // Initial data fetch
        Task {
            do {
                let location = try await locationService.getCurrentLocation()
                
                let resources = try await mapService.searchNearbyPlaces(
                    location: location,
                    types: ResourceCategory.allCases
                )
                
                // Convert place results to resources and save
                let mappedResources = resources.map { result in
                    let resource = Resource()
                    resource.id = result.id
                    resource.name = result.displayName.text
                    resource.type = result.primaryType
                    resource.latitude = result.location.latitude
                    resource.longitude = result.location.longitude
                    resource.address = result.formattedAddress
                    return resource
                }
                
                try await resourceRepository.saveResources(mappedResources)
            } catch {
                print("Error fetching initial resources: \(error)")
            }
        }
    }
} 