import SwiftUI
import CoreLocation
import MapKit
import BridgeConnectKit

@MainActor
final class ResourceViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// List of resources
    @Published private(set) var resources: [Resource] = []
    
    /// Loading state
    @Published private(set) var isLoading = false
    
    /// Error state
    @Published var error: Error?
    
    /// Map region
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    /// Selected resource type filter
    @Published var selectedType: ResourceType?
    
    /// Selected radius filter in meters
    @Published var selectedRadius: Double = 5000
    
    // MARK: - Private Properties
    
    private let repository: ResourceRepository
    
    // MARK: - Initialization
    
    init(repository: ResourceRepository = Core.shared.resourceRepository) {
        self.repository = repository
        Task {
            await refresh()
        }
    }
    
    // MARK: - Public Methods
    
    /// Refresh the list of resources
    func refresh() async {
        isLoading = true
        error = nil
        
        do {
            resources = try await repository.getAll()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Search for resources
    func search(query: String) async {
        guard !query.isEmpty else {
            await refresh()
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            resources = try await repository.search(
                query: query,
                location: CLLocationCoordinate2D(
                    latitude: region.center.latitude,
                    longitude: region.center.longitude
                ),
                radius: selectedRadius
            )
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Update map region and search in the new area
    func updateRegion(_ newRegion: MKCoordinateRegion) async throws {
        region = newRegion
        isLoading = true
        error = nil
        
        do {
            resources = try await repository.searchResources(
                query: nil,
                location: newRegion.center,
                type: selectedType,
                radius: selectedRadius
            )
        } catch {
            self.error = error
            throw error
        }
        
        isLoading = false
    }
    
    /// Apply filters
    func applyFilters(type: ResourceType?, radius: Double) async {
        selectedType = type
        selectedRadius = radius
        
        do {
            try await updateRegion(region)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Private Methods
    
    private func searchInCurrentRegion() async {
        isLoading = true
        error = nil
        
        do {
            resources = try await repository.searchResources(
                query: nil,
                location: region.center,
                type: selectedType,
                radius: selectedRadius
            )
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 