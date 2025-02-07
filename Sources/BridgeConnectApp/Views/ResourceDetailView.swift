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
                        Text("Type: \(resource.type)")
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

struct ResourceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResourceDetailView(resource: Resource(
                name: "Sample Resource",
                resourceDescription: "A sample resource for preview",
                type: "Food Bank",
                latitude: 37.7749,
                longitude: -122.4194,
                address: "123 Main St",
                phone: "555-1234",
                email: "sample@example.com",
                website: "https://example.com"
            ))
        }
    }
} 