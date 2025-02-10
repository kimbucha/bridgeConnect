import SwiftUI
import BridgeConnectKit
import RealmSwift

struct ResourceListView: View {
    @StateObject private var viewModel = ResourceListViewModel()
    @State private var searchText = ""
    @State private var showingAddResource = false
    @State private var isLoading = false
    @State private var selectedCategory: ResourceCategory?
    
    private var filteredResources: [Resource] {
        let resources = viewModel.resources
        let categoryFiltered = selectedCategory == nil ? resources :
            resources.filter { selectedCategory?.types.contains($0.type) ?? false }
        
        if searchText.isEmpty {
            return categoryFiltered
        }
        
        return categoryFiltered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var toolbarContent: some View {
        HStack(spacing: 16) {
            Button(action: { 
                isLoading = true
                Task {
                    await viewModel.searchNearbyResources()
                    isLoading = false
                }
            }) {
                Image(systemName: "location.magnifyingglass")
            }
            .disabled(isLoading)
            
            Button(action: { showingAddResource = true }) {
                Image(systemName: "plus")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CategoryScrollView(
                    selectedCategory: selectedCategory,
                    onSelectCategory: { category in
                        selectedCategory = category
                    }
                )
                
                ResourceListContent(
                    resources: filteredResources,
                    isLoading: isLoading
                )
            }
            .navigationTitle("Resources")
            .searchable(text: $searchText, prompt: "Search resources...")
            .onChange(of: searchText) { newValue in
                viewModel.filterResources(searchText: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarContent
                }
            }
            .sheet(isPresented: $showingAddResource) {
                AddResourceView()
            }
        }
    }
}






struct ResourceListView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceListView()
    }
} 