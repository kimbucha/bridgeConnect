import SwiftUI
import MapKit
import BridgeConnectKit

struct ResourceMapView: View {
    @ObservedObject var viewModel: ResourceViewModel
    @State private var selectedResource: Resource?
    @State private var showingDetail = false
    @State private var lastRegion: MKCoordinateRegion?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(
                coordinateRegion: $viewModel.region,
                annotationItems: viewModel.resources
            ) { resource in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: resource.latitude,
                        longitude: resource.longitude
                    )
                ) {
                    ResourceAnnotationView(
                        resource: resource,
                        isSelected: selectedResource?.id == resource.id
                    ) {
                        selectedResource = resource
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                lastRegion = viewModel.region
            }
            .onChange(of: viewModel.region.center.latitude) { _ in
                checkRegionChange()
            }
            .onChange(of: viewModel.region.center.longitude) { _ in
                checkRegionChange()
            }
            .onChange(of: viewModel.region.span.latitudeDelta) { _ in
                checkRegionChange()
            }
            .onChange(of: viewModel.region.span.longitudeDelta) { _ in
                checkRegionChange()
            }
            
            if let selected = selectedResource {
                ResourcePreviewCard(
                    resource: selected,
                    onDismiss: { selectedResource = nil },
                    onTap: { showingDetail = true }
                )
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: selectedResource)
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDetail, content: {
            if let resource = selectedResource {
                NavigationView {
                    ResourceDetailView(resource: resource)
                        .navigationBarItems(trailing: Button("Done") {
                            showingDetail = false
                        })
                }
            }
        })
    }
    
    private func checkRegionChange() {
        guard let last = lastRegion else { return }
        
        // Check if region has changed significantly (more than 10%)
        let centerChanged = abs(last.center.latitude - viewModel.region.center.latitude) > last.span.latitudeDelta * 0.1 ||
                          abs(last.center.longitude - viewModel.region.center.longitude) > last.span.longitudeDelta * 0.1
        let spanChanged = abs(last.span.latitudeDelta - viewModel.region.span.latitudeDelta) > last.span.latitudeDelta * 0.1 ||
                         abs(last.span.longitudeDelta - viewModel.region.span.longitudeDelta) > last.span.longitudeDelta * 0.1
        
        if centerChanged || spanChanged {
            lastRegion = viewModel.region
            Task {
                do {
                    try await viewModel.updateRegion(viewModel.region)
                } catch {
                    print("Error updating region: \(error)")
                }
            }
        }
    }
}

// MARK: - Resource Annotation View

struct ResourceAnnotationView: View {
    let resource: Resource
    let isSelected: Bool
    let action: () -> Void
    
    private var resourceType: ResourceType? {
        ResourceType(rawValue: resource.type)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(systemName: resourceType?.iconName ?? "questionmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(isSelected ? Color.blue : Color.red)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                
                Image(systemName: "triangle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .blue : .red)
                    .offset(y: -3)
            }
        }
    }
}

// MARK: - Resource Preview Card

struct ResourcePreviewCard: View {
    let resource: Resource
    let onDismiss: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Capsule()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 8)
            }
            
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(resource.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(resource.resourceDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Label(
                            ResourceType(rawValue: resource.type)?.displayName ?? "Other",
                            systemImage: "tag"
                        )
                        .font(.caption)
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("Tap for details")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 5)
        )
        .padding()
    }
}

// MARK: - ResourceType Extension

private extension ResourceType {
    var iconName: String {
        switch self {
        case .foodBank:
            return "basket.fill"
        case .shelter:
            return "house.fill"
        case .medical:
            return "cross.fill"
        case .mentalHealth:
            return "brain.head.profile"
        case .education:
            return "book.fill"
        case .employment:
            return "briefcase.fill"
        case .legal:
            return "building.columns.fill"
        case .transportation:
            return "bus.fill"
        case .childcare:
            return "figure.2.and.child.holdinghands"
        case .clothing:
            return "tshirt.fill"
        case .financial:
            return "dollarsign.circle.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

// MARK: - Preview Provider

struct ResourceMapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResourceMapView(viewModel: ResourceViewModel())
        }
    }
} 