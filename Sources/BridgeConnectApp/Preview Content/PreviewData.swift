import Foundation
import CoreLocation
import BridgeConnectKit

/// Helper struct for creating preview data
struct PreviewData {
    static let sampleResources: [Resource] = [
        Resource(
            name: "Emergency Shelter SF",
            description: "24/7 emergency shelter in San Francisco",
            address: "123 Main St, San Francisco, CA",
            phone: "415-555-0123",
            website: "https://example.com",
            hours: "Open 24/7",
            category: ResourceCategory.categories[0],
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        ),
        Resource(
            name: "Food Bank",
            description: "Free food and meals",
            address: "456 Market St, San Francisco, CA",
            phone: "415-555-0456",
            website: "https://example.com",
            hours: "Mon-Fri 9AM-5PM",
            category: ResourceCategory.categories[1],
            coordinate: CLLocationCoordinate2D(latitude: 37.7899, longitude: -122.4094)
        ),
        Resource(
            name: "Health Clinic",
            description: "Free health services",
            address: "789 Mission St, San Francisco, CA",
            phone: "415-555-0789",
            website: "https://example.com",
            hours: "Mon-Sat 8AM-8PM",
            category: ResourceCategory.categories[2],
            coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294)
        )
    ]
}
