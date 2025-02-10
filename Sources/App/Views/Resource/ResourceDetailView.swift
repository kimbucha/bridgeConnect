import SwiftUI
import MapKit
import BridgeConnectKit

struct ResourceDetailView: View {
    let resource: Resource
    @Environment(\.openURL) private var openURL
    @State private var region: MKCoordinateRegion
    
    init(resource: Resource) {
        self.resource = resource
        let coordinate = CLLocationCoordinate2D(
            latitude: resource.latitude,
            longitude: resource.longitude
        )
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        List {
            // Basic Information
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(resource.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(resource.resourceDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Label(
                        ResourceType(rawValue: resource.type)?.displayName ?? "Other",
                        systemImage: "tag"
                    )
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
            
            // Contact Information
            if hasContactInfo {
                Section("Contact") {
                    if let phone = resource.contactPhone {
                        Button {
                            openURL(URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))")!)
                        } label: {
                            Label(phone, systemImage: "phone")
                        }
                    }
                    
                    if let email = resource.contactEmail {
                        Button {
                            openURL(URL(string: "mailto:\(email)")!)
                        } label: {
                            Label(email, systemImage: "envelope")
                        }
                    }
                    
                    if let website = resource.contactWebsite {
                        Button {
                            openURL(URL(string: website)!)
                        } label: {
                            Label("Visit Website", systemImage: "globe")
                        }
                    }
                }
            }
            
            // Location
            Section("Location") {
                VStack(alignment: .leading, spacing: 12) {
                    Map(coordinateRegion: $region, annotationItems: [resource]) { resource in
                        MapMarker(
                            coordinate: CLLocationCoordinate2D(
                                latitude: resource.latitude,
                                longitude: resource.longitude
                            ),
                            tint: .red
                        )
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    
                    Button {
                        openInMaps()
                    } label: {
                        Label("Open in Maps", systemImage: "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 4)
            }
            
            // Availability
            Section("Availability") {
                Label(resource.availability, systemImage: "clock")
                    .foregroundColor(availabilityColor)
            }
            
            // Last Updated
            Section {
                Text("Last updated \(resource.lastUpdated.formatted(.relative(presentation: .named)))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var hasContactInfo: Bool {
        resource.contactPhone != nil ||
        resource.contactEmail != nil ||
        resource.contactWebsite != nil
    }
    
    private var availabilityColor: Color {
        switch resource.availability.lowercased() {
        case "available":
            return .green
        case "limited":
            return .orange
        case "unavailable", "closed":
            return .red
        default:
            return .secondary
        }
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(
                latitude: resource.latitude,
                longitude: resource.longitude
            )
        )
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = resource.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Preview Provider

struct ResourceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResourceDetailView(resource: Resource(
                id: "1",
                name: "Local Food Bank",
                description: "Provides food assistance to the community",
                type: .foodBank,
                location: CLLocationCoordinate2D(
                    latitude: 37.7749,
                    longitude: -122.4194
                ),
                phone: "555-123-4567",
                email: "info@foodbank.org",
                website: "https://foodbank.org"
            ))
        }
    }
} 