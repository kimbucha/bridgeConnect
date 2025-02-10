import Foundation
import RealmSwift

/// Core module provides the fundamental building blocks of the BridgeConnect application
public final class Core {
    /// Current version of the Core module
    public static let version = "1.0.0"
    
    /// Shared instance of Core
    public static let shared = Core()
    
    public let resourceRepository: ResourceRepository
    public let networkService: NetworkService
    public let logger: Logger
    
    private init() {
        self.resourceRepository = RealmResourceRepository()
        self.networkService = NetworkService()
        self.logger = Logger()
    }
    
    /// Initialize core services and configurations
    public static func initialize() {
        // Configure Realm
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Nothing to migrate yet
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
        
        // Initialize Core
        _ = Core.shared
    }
    
    /// Reset all cached data
    public static func resetCache() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
            shared.logger.log("Cache reset successfully", level: .info)
        } catch {
            shared.logger.log("Failed to reset cache: \(error)", level: .error)
        }
    }
} 