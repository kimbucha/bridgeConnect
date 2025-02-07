import Foundation
import RealmSwift

public enum BridgeConnectKitError: Error {
    case initializationError(String)
}

import RealmSwift

public final class BridgeConnectKit {
    public static let shared = BridgeConnectKit()
    
    private init() {}
    
    public static func initialize() throws {
        // Initialize Realm
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Handle future migrations
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: - Public API
    
    public var resourceRepository: ResourceRepository {
        ResourceRepository.shared
    }
    
    public var locationService: LocationService {
        LocationService.shared
    }
} 