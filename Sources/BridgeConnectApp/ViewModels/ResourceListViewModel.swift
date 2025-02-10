import SwiftUI
import BridgeConnectKit
import RealmSwift
import CoreLocation

class ResourceListViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    private let repository: ResourceRepository
    private let locationService: LocationService
    private let mapService: MapService
    
    init() {
        self.repository = BridgeConnectKit.shared.resourceRepository
        self.locationService = BridgeConnectKit.shared.locationService
        self.mapService = BridgeConnectKit.shared.mapService
        loadResources()
    }
    
    func loadResources() {
        resources = Array(repository.getAllResources())
    }
    
    func searchNearbyResources() async {
        do {
            let location = try await locationService.getCurrentLocation()
            let places = try await mapService.searchNearbyPlaces(
                location: location,
                types: ResourceCategory.categories
            )
            
            // Convert places to resources and save them
            let newResources = places.map { place in
                Resource(
                    id: place.id,
                    name: place.displayName.text,
                    resourceDescription: "",
                    type: place.primaryType,
                    address: place.formattedAddress,
                    coordinate: CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude),
                    phone: "",
                    website: "",
                    hours: [:]
                )
            }
            
            try repository.batchSave(resources: newResources)
            loadResources() // Reload resources from the database
        } catch {
            print("Error fetching nearby resources: \(error)")
        }
    }
    
    func filterResources(searchText: String) {
        if searchText.isEmpty {
            loadResources()
        } else {
            let allResources = repository.getAllResources()
            resources = Array(allResources.filter { resource in
                return resource.name.localizedCaseInsensitiveContains(searchText) ||
                       resource.resourceDescription.localizedCaseInsensitiveContains(searchText) ||
                       resource.type == ResourceType.from(string: searchText).rawValue
            })
        }
    }
}
