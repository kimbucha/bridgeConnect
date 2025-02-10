import Foundation
import CoreLocation

@available(macOS 10.15, *)
public final class LocationService: NSObject, CLLocationManagerDelegate {
    public static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var locationUpdateHandler: ((Result<CLLocation, Error>) -> Void)?
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func requestLocationPermission() async throws {
        if locationManager.authorizationStatus == .notDetermined {
            return try await withCheckedThrowingContinuation { continuation in
                locationUpdateHandler = { result in
                    switch result {
                    case .success(_):
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    @available(macOS 11.0, *)
    public func getCurrentLocation() async throws -> CLLocation {
        try await requestLocationPermission()
        
        #if os(iOS)
        guard locationManager.authorizationStatus == .authorizedWhenInUse || 
              locationManager.authorizationStatus == .authorizedAlways else {
            throw NSError(domain: "LocationService", code: 1, 
                         userInfo: [NSLocalizedDescriptionKey: "Location access denied"])
        }
        #else
        guard locationManager.authorizationStatus == .authorized else {
            throw NSError(domain: "LocationService", code: 1, 
                         userInfo: [NSLocalizedDescriptionKey: "Location access denied"])
        }
        #endif
        
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

