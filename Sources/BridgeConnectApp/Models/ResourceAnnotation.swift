import MapKit
import BridgeConnectKit

/// A map annotation that represents a resource on the map
class ResourceAnnotation: NSObject, MKAnnotation {
    let resource: Resource
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: resource.latitude, longitude: resource.longitude)
    }
    
    var title: String? {
        resource.name
    }
    
    var subtitle: String? {
        resource.address
    }
    
    init(resource: Resource) {
        self.resource = resource
        super.init()
    }
}
