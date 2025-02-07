import Foundation
import CoreLocation

public final class LocationService: NSObject, CLLocationManagerDelegate {
    public static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var locationUpdateHandler: ((Result<CLLocation, Error>) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func getCurrentLocation() async throws -> CLLocation {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse || 
              locationManager.authorizationStatus == .authorizedAlways else {
            throw NSError(domain: "LocationService", code: 1, 
                         userInfo: [NSLocalizedDescriptionKey: "Location access denied"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            locationUpdateHandler = { result in
                continuation.resume(with: result)
            }
            locationManager.requestLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationUpdateHandler?(.success(location))
            locationUpdateHandler = nil
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationUpdateHandler?(.failure(error))
        locationUpdateHandler = nil
    }
}

