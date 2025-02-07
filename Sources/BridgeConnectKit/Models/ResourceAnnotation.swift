import Foundation
import MapKit

public struct ResourceAnnotation: Identifiable {
    public let id = UUID()
    public let coordinate: CLLocationCoordinate2D
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
