import Foundation
import MapKit

public struct ResourceAnnotation: Identifiable {
    public let id: String
    public let name: String
    public let resourceType: String
    public let coordinate: CLLocationCoordinate2D
    
    public init(resource: Resource) {
        self.id = resource.id
        self.name = resource.name
        self.resourceType = resource.type
        self.coordinate = CLLocationCoordinate2D(latitude: resource.latitude, longitude: resource.longitude)
    }
}
