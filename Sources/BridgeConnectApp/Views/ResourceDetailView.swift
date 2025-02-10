import SwiftUI
import MapKit
import BridgeConnectKit

struct ResourceDetailView: View {
    let resource: Resource
    @State private var region: MKCoordinateRegion
    @State private var showingEditSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    init(resource: Resource) {
        self.resource = resource
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: resource.latitude,
                longitude: resource.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Map preview
                Map(coordinateRegion: $region, annotationItems: [resource]) { resource in
                    MapMarker(coordinate: CLLocationCoordinate2D(
                        latitude: resource.latitude,
                        longitude: resource.longitude
                    ))
                }
                .frame(height: 200)
                .cornerRadius(12)
                
                // Resource details
                VStack(alignment: .leading, spacing: 12) {
                    Text(resource.name)
                        .font(.title)
                        .bold()
                    
                    Text(resource.resourceDescription)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Contact information
                    if !resource.address.isEmpty {
                        ContactRow(icon: "location.fill", text: resource.address)
                    }
                    
                    if !resource.phone.isEmpty {
                        Button(action: { callPhone(resource.phone) }) {
                            ContactRow(icon: "phone.fill", text: resource.phone)
                        }
                    }
                    
                    if !resource.email.isEmpty {
                        Button(action: { sendEmail(resource.email) }) {
                            ContactRow(icon: "envelope.fill", text: resource.email)
                        }
                    }
                    
                    if !resource.website.isEmpty {
                        Button(action: { openWebsite(resource.website) }) {
                            ContactRow(icon: "globe", text: resource.website)
                        }
                    }
                    
                    Divider()
                    
                    // Metadata
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type: \(ResourceType.from(string: resource.type).displayName)")
                            .font(.subheadline)
                        Text("Last updated: \(formattedDate(resource.updatedAt))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditResourceView(resource: resource)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func callPhone(_ number: String) {
        guard let url = URL(string: "tel://\(number.replacingOccurrences(of: " ", with: ""))") else { return }
        UIApplication.shared.open(url)
    }
    
    private func sendEmail(_ email: String) {
        guard let url = URL(string: "mailto:\(email)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func openWebsite(_ website: String) {
        guard let url = URL(string: website) else { return }
        UIApplication.shared.open(url)
    }
}

struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            Text(text)
                .foregroundColor(.accentColor)
        }
    }
}

#if DEBUG
struct ResourceDetailView_Previews: PreviewProvider {
    static let sampleResource = Resource(
        id: UUID().uuidString,
        name: "Emergency Shelter SF",
        resourceDescription: "24/7 emergency shelter in San Francisco with food and basic amenities. Open to all individuals in need of temporary housing.",
        type: "shelter",
        address: "123 Main St, San Francisco, CA 94105",
        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        phone: "(415) 555-0123",
        website: "https://example.com",
        hours: ["Monday": "Open 24/7", "Tuesday": "Open 24/7", "Wednesday": "Open 24/7", "Thursday": "Open 24/7", "Friday": "Open 24/7", "Saturday": "Open 24/7", "Sunday": "Open 24/7"]
    )
    
    static var previews: some View {
        NavigationView {
            ResourceDetailView(resource: sampleResource)
        }
    }
    
    // Preview different states and configurations
    static var previewStates: some View {
        Group {
            // Default view
            NavigationView {
                ResourceDetailView(resource: sampleResource)
            }
            .previewDisplayName("Default")
            
            // Dark mode
            NavigationView {
                ResourceDetailView(resource: sampleResource)
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            // Large text
            NavigationView {
                ResourceDetailView(resource: sampleResource)
            }
            .environment(\.sizeCategory, .accessibilityLarge)
            .previewDisplayName("Large Text")
            
            // Right-to-left
            if #available(iOS 15.0, *) {
                NavigationView {
                    ResourceDetailView(resource: sampleResource)
                }
                .environment(\.layoutDirection, .rightToLeft)
                .previewDisplayName("Right to Left")
            }
        }
    }
    
    // Preview different devices
    static var previewDevices: some View {
        Group {
            NavigationView {
                ResourceDetailView(resource: sampleResource)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            .previewDisplayName("iPhone 14 Pro")
            
            NavigationView {
                ResourceDetailView(resource: sampleResource)
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewDisplayName("iPhone SE")
            
            if #available(iOS 15.0, *) {
                NavigationView {
                    ResourceDetailView(resource: sampleResource)
                }
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDisplayName("Landscape")
            }
        }
    }
}
#endif