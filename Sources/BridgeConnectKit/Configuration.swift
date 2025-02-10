import Foundation

public final class Configuration {
    public static let shared = Configuration()
    
    public private(set) var googlePlacesApiKey: String
    
    private init() {
        #if DEBUG
        googlePlacesApiKey = ProcessInfo.processInfo.environment["GOOGLE_PLACES_KEY"] ?? ""
        #else
        // In production, load from a secure source
        googlePlacesApiKey = ""
        #endif
        
        assert(!googlePlacesApiKey.isEmpty, "Google Places API Key not configured")
    }
    
    public func configure(googlePlacesApiKey: String) {
        self.googlePlacesApiKey = googlePlacesApiKey
    }
}
