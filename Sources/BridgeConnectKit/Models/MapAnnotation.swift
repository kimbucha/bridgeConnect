import MapKit

public struct LocationAnnotation: Identifiable {
    public let id = UUID()
    public let coordinate: CLLocationCoordinate2D
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
