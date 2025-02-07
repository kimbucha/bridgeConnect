import SwiftUI
import MapKit
import BridgeConnectKit

struct ResourceMapView: View {
    @StateObject private var viewModel = ResourceMapViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.resources) { resource in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: resource.latitude, longitude: resource.longitude)) {
                NavigationLink(destination: ResourceDetailView(resource: resource)) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        Text(resource.name)
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .navigationTitle("Map")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.requestLocationPermission) {
                    Image(systemName: "location")
                }
            }
        }
        .task {
            await viewModel.getCurrentLocation()
        }
    }
}

@MainActor
class ResourceMapViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var userLocation: CLLocation?
    
    private let repository = BridgeConnectKit.shared.resourceRepository
    private let locationService = BridgeConnectKit.shared.locationService
    
    init() {
        loadResources()
    }
    
    func loadResources() {
        let results = repository.getAllResources()
        resources = Array(results)
    }
    
    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
    
    func getCurrentLocation() async {
        do {
            let location = try await locationService.getCurrentLocation()
            userLocation = location
            await MainActor.run {
                updateNearbyResources(location: location)
            }
        } catch {
            print("Error getting location: \(error)")
        }
    }
    
    private func updateNearbyResources(location: CLLocation) {
        let results = repository.getNearbyResources(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            radiusInMeters: 5000
        )
        self.resources = Array(results)
    }
}

struct ResourceMapView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceMapView()
    }
} 