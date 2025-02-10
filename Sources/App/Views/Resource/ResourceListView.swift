import SwiftUI
import CoreLocation
import BridgeConnectKit

struct ResourceListView: View {
    @ObservedObject var viewModel: ResourceViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showingFilters = false
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading resources...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.resources.isEmpty {
                EmptyStateView()
            } else {
                resourceList
            }
        }
        .navigationTitle("Resources")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFilters = true
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private var resourceList: some View {
        if horizontalSizeClass == .regular {
            List {
                ForEach(viewModel.resources, id: \.id) { resource in
                    NavigationLink {
                        ResourceDetailView(resource: resource)
                    } label: {
                        ResourceRowView(resource: resource)
                    }
                }
            }
            .listStyle(.insetGrouped)
        } else {
            List {
                ForEach(viewModel.resources, id: \.id) { resource in
                    NavigationLink {
                        ResourceDetailView(resource: resource)
                    } label: {
                        ResourceRowView(resource: resource)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Empty State View

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Resources Found")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Try adjusting your search or filters to find more resources.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Resource Row View

struct ResourceRowView: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(resource.name)
                .font(.headline)
            
            Text(resource.resourceDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 12) {
                Label(
                    ResourceType(rawValue: resource.type)?.displayName ?? "Other",
                    systemImage: "tag"
                )
                .font(.caption)
                .foregroundColor(.blue)
                
                if let phone = resource.contactPhone {
                    Label(phone, systemImage: "phone")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview Provider

struct ResourceListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResourceListView(viewModel: ResourceViewModel())
        }
    }
} 