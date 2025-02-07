import SwiftUI
import BridgeConnectKit
import RealmSwift

struct ResourceListView: View {
    @StateObject private var viewModel = ResourceListViewModel()
    @State private var searchText = ""
    @State private var showingAddResource = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.resources, id: \.id) { resource in
                    NavigationLink(destination: ResourceDetailView(resource: resource)) {
                        ResourceRowView(resource: resource)
                    }
                }
            }
            .navigationTitle("Resources")
            .searchable(text: $searchText)
            .onChange(of: searchText) { newValue in
                viewModel.search(query: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddResource = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddResource) {
                AddResourceView()
            }
        }
    }
}

class ResourceListViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    private let repository = BridgeConnectKit.shared.resourceRepository
    
    init() {
        loadResources()
    }
    
    func loadResources() {
        let results = repository.getAllResources()
        resources = Array(results)
    }
    
    func search(query: String) {
        if query.isEmpty {
            loadResources()
        } else {
            let results = repository.searchResources(query: query)
            resources = Array(results)
        }
    }
}

struct ResourceRowView: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(resource.name)
                .font(.headline)
            Text(resource.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

struct ResourceListView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceListView()
    }
} 