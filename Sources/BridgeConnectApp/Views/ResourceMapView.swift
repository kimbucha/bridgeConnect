import SwiftUI
import MapKit
import BridgeConnectKit
import Combine
import UIKit

fileprivate struct MapCategoryScrollView: View {
    let selectedCategory: ResourceCategory?
    let onSelectCategory: (ResourceCategory?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                Button(action: { onSelectCategory(nil) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                        Text("All")
                            .font(.subheadline)
                            .bold()
                    }
                    .foregroundColor(selectedCategory == nil ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selectedCategory == nil ? Color.accentColor : Color(.systemGray6))
                    .clipShape(Capsule())
                }
                
                ForEach(ResourceCategory.categories) { category in
                    MapCategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation {
                            onSelectCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground).opacity(0.9))
    }
}

fileprivate struct MapCategoryButton: View {
    let category: ResourceCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.title)
                    .font(.subheadline)
                    .bold()
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color(.systemGray6))
            .clipShape(Capsule())
        }
    }
}

fileprivate struct ResourceAnnotation: Identifiable {
    let id: String
    let latitude: Double
    let longitude: Double
    let resource: Resource
    
    init(resource: Resource) {
        self.id = resource.id
        self.latitude = resource.latitude
        self.longitude = resource.longitude
        self.resource = resource
    }
}

@available(iOS 15.0, *)
struct ResourceMapView: View {
    @StateObject private var viewModel = ResourceMapViewModel()
    @State private var selectedResource: Resource?
    @State private var showingResourceDetail = false
    @State private var showLocationDeniedAlert = false
    
    var body: some View {
        ZStack {
            // Map View
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.resources.map { ResourceAnnotation(resource: $0) }) { annotation in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude)) {
                    Button(action: {
                        selectedResource = annotation.resource
                        showingResourceDetail = true
                    }) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                            .shadow(radius: 2)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                MapCategoryScrollView(
                    selectedCategory: viewModel.selectedCategory,
                    onSelectCategory: viewModel.selectCategory
                )
                .padding(.top, 8)
                
                Spacer()
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .navigationTitle("Resources")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.getCurrentLocation()
                        } catch {
                            showLocationDeniedAlert = true
                        }
                    }
                }) {
                    Image(systemName: "location.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingResourceDetail) {
            if let resource = selectedResource {
                ResourceDetailView(resource: resource)
            }
        }
        .alert("Location Access Required", isPresented: $showLocationDeniedAlert) {
            Button("Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable location access in Settings to find resources near you.")
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.getCurrentLocation()
                } catch {
                    showLocationDeniedAlert = true
                }
            }
        }
    }
}

#if DEBUG
struct ResourceMapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResourceMapView()
        }
    }
}
#endif

