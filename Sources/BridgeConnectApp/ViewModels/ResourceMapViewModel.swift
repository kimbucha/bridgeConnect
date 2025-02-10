import SwiftUI
import BridgeConnectKit
import CoreLocation
import MapKit
import Combine

@available(iOS 15.0, *)
@MainActor
class ResourceMapViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var selectedCategory: ResourceCategory?
    @Published var isLoading = false
    
    private let repository: ResourceRepository
    private let locationService: LocationService
    private let mapService: MapService
    
    
    init() {
        self.repository = BridgeConnectKit.shared.resourceRepository
        self.locationService = BridgeConnectKit.shared.locationService
        self.mapService = BridgeConnectKit.shared.mapService
        Task { await loadResources() }
    }
    
    func requestLocationPermission() async throws {
        try await locationService.requestLocationPermission()
    }
    
    func getCurrentLocation() async throws {
        let location = try await locationService.getCurrentLocation()
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        try await updateUserLocation()
    }
    
    @MainActor
    func loadResources() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let location = try await locationService.getCurrentLocation()
            let searchResults = try await mapService.searchNearbyPlaces(
                location: location,
                types: selectedCategory.map { [$0] } ?? ResourceCategory.allCases
            )
            
            resources = searchResults.map { result in
                Resource(
                    id: result.id,
                    name: result.displayName.text,
                    resourceDescription: "",
                    type: result.primaryType,
                    address: result.formattedAddress,
                    coordinate: CLLocationCoordinate2D(latitude: result.location.latitude, longitude: result.location.longitude),
                    phone: "",
                    website: "",
                    hours: [:]
                )
            }
        } catch {
            print("Error loading resources: \(error)")
            resources = []
        }
    }
    
    func selectCategory(_ category: ResourceCategory?) {
        selectedCategory = category
        Task {
            await loadResources()
        }
    }
    
    func updateUserLocation() async throws {
        let location = try await locationService.getCurrentLocation()
        let allResources = repository.getAllResources()
        
        try repository.realm.write {
            allResources.forEach { resource in
                let resourceLocation = CLLocation(latitude: resource.latitude, longitude: resource.longitude)
                let distance = location.distance(from: resourceLocation)
                resource.distanceMeters = Int(distance)
                resource.distanceText = formatDistance(meters: Int(distance))
            }
        }
        
        resources = Array(allResources)
    }
    
    private func formatDistance(meters: Int) -> String {
        if meters < 1000 {
            return "\(meters)m"
        } else {
            let kilometers = Double(meters) / 1000.0
            return String(format: "%.1fkm", kilometers)
        }
    }
    
    func resourceType(for resource: Resource) -> String {
        return ResourceType.from(string: resource.type).displayName
    }
}
